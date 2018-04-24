DOCKER=docker
NETWORK_NAME=eth-testname
DOCKER_RUN_ARGS=--detach --tty --interactive --network $(NETWORK_NAME)
BOOTNODE_IMG=eth-bootnode
NODE_IMG=eth-node
NODES_NUM=3
BUILD_DIR=./build
CONTRACT_SOL=package_delivery.sol

all: run

run: run_bootnode run_nodes

run_bootnode: setup build_bootnode clean_bootnode
	$(DOCKER) run $(DOCKER_RUN_ARGS) --name eth-bootnode $(BOOTNODE_IMG)

run_nodes: setup build_node clean_nodes
	for i in $$(seq 1 $(NODES_NUM)); do \
		$(DOCKER) run $(DOCKER_RUN_ARGS) --name eth-node$$i --env "eth_acc=acc$$i" $(NODE_IMG);\
	done

setup: setup_network build_contract

setup_network:
	-$(DOCKER) network create --internal $(NETWORK_NAME)

build: build_bootnode build_node build_contract

build_contract: $(CONTRACT_SOL)
	mkdir -p $(BUILD_DIR)
	docker run -v $$(pwd):/_input:ro -v $$(cd $(BUILD_DIR); pwd):/_output:rw -i ethereum/solc:0.4.23 --combined-json abi,bin --overwrite -o /_output /_input/$(CONTRACT_SOL)
	./create_crontract_script.py

build_base: baseimg.docker
	$(DOCKER) build -f baseimg.docker -t eth-base .

build_bootnode: build_base bootnode.docker
	$(DOCKER) build -f bootnode.docker -t $(BOOTNODE_IMG) .

build_node: build_base node.docker
	$(DOCKER) build -f node.docker -t $(NODE_IMG) .

clean: clean_contract clean_containers clean_images clean_network

clean_contract:
	-rm -rf package_delivery_contract.js $(BUILD_DIR)

clean_images:
	-$(DOCKER) rmi eth-base $(BOOTNODE_IMG) $(NODE_IMG)

clean_network:
	-$(DOCKER) network rm $(NETWORK_NAME)

clean_containers: clean_bootnode clean_nodes

clean_bootnode:
	-$(DOCKER) rm -f eth-bootnode

clean_nodes:
	-$(DOCKER) rm -f $$(for i in $$(seq 1 $(NODES_NUM)); do echo "eth-node$$i"; done)
