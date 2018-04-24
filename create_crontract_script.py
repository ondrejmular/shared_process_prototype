#!/usr/bin/env python

import json

contract = json.load(
    open("./build/combined.json")
)["contracts"]["/_input/package_delivery.sol:PackageDelivery"]
with open("package_delivery_contract.js", "w+") as f:
    f.write("""\
var packageDeliveryAbi = {abi};
var packageDeliveryCode = '0x{code}';

""".format(abi=contract["abi"], code=contract["bin"])
    )
