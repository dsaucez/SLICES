# SLICES Blueprint

We are currently working on a newer version of the blueprint reference implementation that may break the hands’on presented in this document.
During this transition if you want to practice with our hands’on please follow the MOOC mentioned below:

This documentation describes the SLICES blueprint. Historically blueprints were used to produce unlimited numbers of accurate copies of plans. For SLICES, the concept is taken to allow each site to reproduce software and hardware architectures on the SLICES sites and nodes. The SLICES blueprint targets testbed owners and operators, it is not intended to be used by experimenters or testbed users. The blueprint is an way to eventually reach a unified architecture between sites and nodes composing SLICES and easily onboard members to fields of research that may not be their core business and so learn about the needs and best practices to make SLICES a success.

With the blueprint, sites are able to deploy and operate partial or full 5G networks, with simulated and/or hardware components.

The blueprint is designed in a modular way such that one can either deploy it fully or only partially. For example, people only interested in 5G can only deploy the core and use a simulated RAN while people interested only by the RAN can just deploy a RAN, assuming they have access to a core (e.g., via the SLICE central node or another partner). Advanced users may even deploy a core and connect it with multiple RANs.
