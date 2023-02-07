---
title: 10 - Principes de conception et architecture détaillée de Kubernetes
draft: true
weight: 2100
---
# Kubernetes design concepts and detailed architecture

The notion of declarative configuration—when a user declares a desired state of the world to produce a result—is one of the primary drivers behind the development of Kubernetes

“I want there to be five replicas of my web server running at all times.” Kubernetes, in turn, takes that declarative statement and takes responsibility for ensuring that it is true.

The power of the declarative approach (that is more complex) is that you are giving the system more than a sequence of instructions—you are giving it a declaration of your desired state. Because Kubernetes understands your desired state, it can take autonomous action, independent of user interaction. This means that it can implement automatic self-correcting and self-healing behaviors. For a developer, this is critical, since it means that the system can fix itself without waking you up in the middle of the night.

## Reconciliation or Controllers

To achieve these self-healing or self-correcting behaviors, Kubernetes is structured based on a large number of independent reconciliation or control loops. When designing a system like Kubernetes, there are generally two different approaches that you can take—a monolithic state-based approach or a decentralized controller–based approach.

Kubernetes takes an alternative decentralized approach in its design. Instead of a single monolithic controller, Kubernetes is composed of a large number of controllers, each performing its own independent reconciliation loop. Each individual loop is only responsible for a small piece of the system (e.g., updating the list of endpoints for a particular load balancer), and each small controller is wholly unaware of the rest of the world. This focus on a small problem and the corresponding ignorance of the broader state of the world makes the entire system significantly more stable. Each controller is largely independent of all others and thus unaffected by problems or changes unrelated to itself. The downside, though, of this distributed approach is that the overall behavior of the system can be harder to understand, since there is no single location to look for an explanation of why the system is behaving the way that it is. Instead, it is necessary to look at the interoperation of a large number of independent processes. The control loop design pattern makes Kubernetes more flexible and stable and is repeated throughout Kubernetes’ system components. The basic idea behind a control loop is that it is continually repeating the following steps:
1. Obtain the desired state of the world.
2. Observe the world.
3. Find differences between the observation of the world and the desired state of the
world.
4. Take actions to make the observation of the world match the desired state.

The easiest example to help you understand the operation of a reconciliation control
loop is the thermostat in your home. It has a desired state (the temperature that you
entered on the thermostat), it makes observations of the world (the current tempera‐
ture of your house), it finds the difference between these values, and it then takes
actions (either heating or cooling) to make the real world match the desired state of
the world.

 “I want four replicas of that web server.” The
Kubernetes replication controller takes this desired state and then observes the world.
It might see that there are currently three replicas of the web-serving container. The
controller finds the difference between the current and desired state (one missing web
server) and then takes action to make the current state match the desired state by cre‐
ating a fourth web-serving container

# Identifyfing resources in a changing environment

the challenges of managing this declarative state is determining the
set of resources that the reconciliation control loop should be paying attention to.
This is where labels and label queries are useful in the Kubernetes design.

 When grouping things together into a set, there
are two possible approaches—explicit/static or implicit/dynamic grouping. With static
grouping, every group is defined by a concrete list (e.g., “The members of my team
are Alice, Bob, and Carol.”). The list explicitly calls out the name of each member of
the group, and the list is static—that is, the membership doesn’t change unless the list
itself changes

But —it cannot respond to a dynami‐
cally changing world. Hopefully, at this point, you know that Kubernetes uses a more
dynamic approach to grouping. In Kubernetes, groups are implicitly defined.

 With implicit
groups, instead of the list of members, the group is defined by a statement like, “The
members of my team are the people wearing orange.” This group is implicitly defined.
Nowhere in the definition of the group are the members defined; instead, they are
implied by evaluating the group definition against a set of people who are present.
Because the set of people who are present can always change, the membership of the
group is likewise dynamic and changing. Although this can introduce complexity,
because of the second step (in the example case, looking for people wearing orange),
it is also significantly more flexible and stable, and it can handle a changing environ‐
ment without requiring constant adjustments to static lists

In Kubernetes, this implicit grouping is achieved via labels and label queries or label
selectors. Every API object in Kubernetes can have an arbitrary number of key/value
pairs called “labels” that are associated with the object. You can then use a label query
or label selector to identify a set of objects that matches that query

# Unix Philosophy of Many Components

Kubernetes ascribes to the general Unix philosophy of modularity and of small pieces
that do their jobs well. Kubernetes is not a single monolithic application that imple‐
ments all of the various functionality in a single binary. Instead, it is a collection of
different applications that all work together, largely ignorant of each other, to imple‐
ment the overall system known as Kubernetes. Even when there is a binary (e.g., the
controller manager) that groups together a large number of different functions, those
functions are held almost entirely independently from each other in that binary. They
are compiled together largely to make the task of deploying and managing Kuber‐
netes easier, not because of any tight binding between the components.

# API-Driven Interactions

The second structural design within Kubernetes is that all interaction between com‐
ponents is driven through a centralized API surface area. An important corollary of
this design is that the API that the components use is the exact same API used by
every other cluster user. This has two important consequences for Kubernetes. The
first is that no part of the system is more privileged or has more direct access to inter‐
nals than any other. Indeed, with the exception of the API server that implements the
API, no one has access to the internals at all. Thus, every component can be swapped
for an alternative implementation, and new functionality can be added without rear‐
chitecting the core components. As we will see in later chapters, even core compo‐
nents like the scheduler can be swapped out and replaced (or merely augmented)
with alternative implementations.

# Looking again at control plane components

## etcd
The etcd system is at the heart of any Kubernetes cluster. It implements the key-value
stores where all of the objects in a Kubernetes cluster are persisted. The etcd servers
implement a distributed consensus algorithm, namely Raft, which ensures that even if
one of the storage servers fails, there is sufficient replication to maintain the data
stored in etcd and to recover data when an etcd server becomes healthy again and re-
adds itself to the cluster. The etcd servers also provide two other important pieces of
functionality that Kubernetes makes heavy use of. The first is optimistic concurrency.
Every value stored in etcd has a corresponding resource version. When a key-value
pair is written to an etcd server, it can be conditionalized on a particular resource ver‐
sion. This means that, using etcd, you can implement compare and swap, which is at
the core of any concurrency system. Compare and swap enables a user to read a value
and update it knowing that no other component in the system has also updated the
value. These assurances enable the system to safely have multiple threads manipulat‐
ing data in etcd without the need for pessimistic locks, which can significantly reduce
throughput to the server.
In addition to implementing compare and swap, the etcd servers also implement a
watch protocol. The value of watch is that it enables clients to efficiently watch for
changes in the key-value stores for an entire directory of values. As an example, all
objects in a Namespace are stored within a directory in etcd. The use of a watch ena‐
bles a client to efficiently wait for and react to changes without continuous polling of
the etcd server.

## API server
Although etcd is at the core of a Kubernetes cluster, there is actually only a single
server that is allowed to have direct access to the Kubernetes cluster, and that is the
API server. The API server is the hub of the Kubernetes cluster; it mediates all inter‐
actions between clients and the API objects stored in etcd. Consequently, it is the cen‐
tral meeting point for all of the various components. Because of its importance, the
API server deserves deeper introspection and is covered in Chapter 4.

## Scheduler
With etcd and the API server operating correctly, a Kubernetes cluster is, in some
ways, functionally complete. You can create all of the different API objects, like
Deployments and Pods. However, you will find that it never begins to run. Finding a
location for a Pod to run is the job of the Kubernetes scheduler. The scheduler scans
the API server for unscheduled Pods and then determines the best nodes on which to
run them. Like the API server, the scheduler is a complex and rich topic that is cov‐
ered more deeply in Chapter 5.

## Controller manager

After etcd, the API server, and the scheduler are operational, you can successfully cre‐
ate Pods and see them scheduled out onto nodes, but you will find that ReplicaSets,
Deployments, and Services don’t work as you expect them to. This is because all of
the reconciliation control loops needed to implement this functionality are not cur‐
rently running. Executing these loops is the job of the controller manager. The con‐
troller manager is the most varied of all of the Kubernetes components, since it has
within it numerous different reconciliation control loops to implement many parts of
the overall Kubernetes system.

# Worker nodes components

# Kubelet

The kubelet is the node daemon for all machines that are part of a Kubernetes cluster.
The kubelet is the bridge that joins the available CPU, disk, and memory for a node
into the large Kubernetes cluster. The kubelet communicates with the API server to
find containers that should be running on its node. Likewise, the kubelet communi‐
cates the state of these containers back up to the API server so that other reconcilia‐
tion control loops can observe the current state of these containers.
In addition to scheduling and reporting the state of containers running in Pods on
their machines, kubelets are also responsible for health checking and restarting the
containers that are supposed to be executing on their machines. It would be quite
inefficient to push all of the health-state information back up to the API server so that
reconciliation loops can take action to fix the health of a container on a particular
machine. Instead, the kubelet shortcircuits this interaction and runs the reconcilia‐
tion loop itself. Thus, if a container being run by the kubelet dies or fails its health
check, the kubelet restarts it, while also communicating this health state (and the
restart) back up to the API server.

# kube-proxy

See advanced network part.
<!-- The other component that runs on all machines is the kube-proxy. The kube-proxy
is responsible for implementing the Kubernetes Service load-balancer networking
model. The kube-proxy is always watching the endpoint objects for all Services in the
Kubernetes cluster. The kube-proxy then programs the network on its node so that
network requests to the virtual IP address of a Service are, in fact, routed to the end‐
points that implement this Service. Every Service in Kubernetes gets a virtual IP
address, and the kube-proxy is the daemon responsible for defining and implement‐ -->

KubeDNS

See advanced network part.

<!-- The first of these scheduled components is the KubeDNS server. When a Kubernetes
Service is created, it gets a virtual IP address, but that IP address is also programmed
into a DNS server for easy service discovery. The KubeDNS containers implement
this name-service for Kubernetes Service objects. The KubeDNS Service is itself
expressed as a Kubernetes Service, so the same routing provided by the kube-proxy
routes DNS traffic to the KubeDNS containers. The one important difference is that
the KubeDNS service is given a static virtual IP address. This means that the API
server can program the DNS server into all of the containers that it creates, imple‐
menting the naming and service discovery for Kubernetes services.
In addition to the KubeDNS service that has been present in Kubernetes since the
first versions, there is also a newer alternative CoreDNS implementation that reached
general availability (GA) in the 1.11 release of Kubernetes.
The ability for the DNS service to be swapped out shows both the modularity and the
value of using Kubernetes to run components like the DNS server. Replacing
KubeDNS with CoreDNS is as easy as stopping one Pod and starting another. -->

## Heapster

The other scheduled component is a binary called Heapster, which is responsible for
collecting metrics like CPU, network, and disk usage from all containers running
inside the Kubernetes cluster. These metrics can be pushed to a monitoring system,
like InfluxDB, for alerting and general monitoring of application health in the cluster.
Also, importantly, these metrics are used to implement autoscaling of Pods within the
Kubernetes cluster. Kubernetes has an autoscaler implementation, that, for example,
can automatically scale the size of a Deployment whenever the CPU usage of the con‐
tainers in the Deployment goes above 80%. Heapster is the component that collects
and aggregates these metrics to power the reconciliation loop implemented by the
autoscaler. The autoscaler observes the current state of the world through API calls to
Heapster.