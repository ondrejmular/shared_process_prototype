pragma solidity ^0.4.23;

contract Process {
    enum State {
        Initiated,  // 0
        InProgress, // 1
        Ended       // 2
    }
    State public state;

    modifier is_in_progress() {
        require(state == State.InProgress, "Process is not in progress");
        _;
    }

    constructor() public {
        state = State.Initiated;
    }

    function start() internal {
        require(state == State.Initiated, "Process has been already started");
        state = State.InProgress;
    }

    function end() internal is_in_progress() {
        state = State.Ended;
    }

    function get_process_state() public view returns(State) {
        return state;
    }
}

contract PackageDelivery is Process {
    address public sender;
    address public carrier;
    address public recipient;
    uint failed_deliveries;
    uint delivered_confirmation_until;
    // set to lower timeout for testing
    uint delivered_confirmation_timeout = 60; // in seconds

    enum PackageDeliveryState {
        Preparing,           // 0
        HandoverToCarrier,   // 1
        InDelivery,          // 2
        HandoverToRecipient, // 3
        Delivered,           // 4
        ReturningToSender,   // 5
        HandoverToSender,    // 6
        Returned             // 7
    }

    PackageDeliveryState package_state;

    modifier allowed_actor(address _actor) {
        require(msg.sender == _actor, "Not authorized");
        _;
    }

    modifier package_in_state(PackageDeliveryState _state) {
        require(_state == package_state, "Invalid action");
        _;
    }

    constructor(address _carrier, address _recipient) public {
        failed_deliveries = 0;
        sender = msg.sender;
        carrier = _carrier;
        recipient = _recipient;
        start();
        package_state = PackageDeliveryState.Preparing;
    }

    function get_status() public view returns (PackageDeliveryState) {
        return package_state;
    }

    function hand_over_to_carrier()
        public
        is_in_progress()
        allowed_actor(sender)
        package_in_state(PackageDeliveryState.Preparing)
    {
        package_state = PackageDeliveryState.HandoverToCarrier;
    }

    function accept_package_for_delivery()
        public
        is_in_progress()
        allowed_actor(carrier)
        package_in_state(PackageDeliveryState.HandoverToCarrier)
    {
        package_state = PackageDeliveryState.InDelivery;
    }

    function hand_over_to_recipient()
        public
        is_in_progress()
        allowed_actor(carrier)
        package_in_state(PackageDeliveryState.InDelivery)
    {
        package_state = PackageDeliveryState.HandoverToRecipient;
        delivered_confirmation_until = now + delivered_confirmation_timeout;
    }

    function accept_package()
        public
        is_in_progress()
        allowed_actor(recipient)
        package_in_state(PackageDeliveryState.HandoverToRecipient)
    {
        require(
            now <= delivered_confirmation_until,
            "Delivery confirmation timed out."
        );
        package_state = PackageDeliveryState.Delivered;
        end();
    }

    function unable_to_deliver()
        public
        is_in_progress()
        allowed_actor(carrier)
        package_in_state(PackageDeliveryState.HandoverToRecipient)
    {
        require(
            now > delivered_confirmation_until,
            "Delivery confirmation didn't time out yet."
        );
        failed_deliveries++;
        if (failed_deliveries >= 3) {
            package_state = PackageDeliveryState.ReturningToSender;
        } else {
            package_state = PackageDeliveryState.InDelivery;
        }
    }

    function return_to_sender()
        public
        is_in_progress()
        allowed_actor(carrier)
        package_in_state(PackageDeliveryState.ReturningToSender)
    {
        package_state = PackageDeliveryState.HandoverToSender;
    }

    function confirm_pkg_return()
        public
        is_in_progress()
        allowed_actor(sender)
        package_in_state(PackageDeliveryState.HandoverToSender)
    {
        package_state = PackageDeliveryState.Returned;
        end();
    }
}

