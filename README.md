# heterogeneousRTOS
Software project part of @GilgameshJR Master's thesis, @federeghe co-advisor.
The project is based on FreeRTOS and targets a Xilinx Zynq FPGA.
Project description:
Ionizing particles in the atmosphere may strike registers and memory cells causing Single Event Upsets (SEU), temporarily tampering the output correctness. SEUs could be dangerous for critical systems, in which a fault could lead to unacceptable consequences. Critical systems are traditionally custom-designed, typically featuring hardware redundancy for guaranteeing fault resilience. Additionally, they are often real-time, requiring to meet strict timing constraints. The downsides of such custom systems are typically weight, power, energy, space, and cost, compared to \emph{Commercial Off-the-Shelf} (COTS) solutions. In this thesis, we explored the use of COTS in critical real-time environments by designing a CPU-FPGA heterogeneous system, which features an ARM CPU, running a modified version of a real-time operating system, and an FPGA, on which the fault-detector and the scheduler are synthesized, in a redundant configuration for increasing fault resiliency. Moving the scheduler to the FPGA increases its fault resiliency while removing the periodic scheduler execution overhead; similarly, synthesizing the fault detector on the FPGA allows the execution of the fault detection in a fault-tolerant way without wasting CPU time. Transient fault resiliency in application tasks is achieved via fault detection and the subsequent fault recovery via re-execution. The fault detector implemented on FPGA uses a machine learning technique to learn the behaviour of tasks (offline and possibly online) and analyses it during their execution. Regarding fault recovery, the scheduler on the FPGA features a novel mixed-criticality scheduling algorithm that manages re-executions, ensuring the meeting of tasks' timing constraints. The fault detection showed noticeable results while providing a lower overhead than general-purpose software techniques for improving fault resiliency. To the best of our knowledge, the integrated CPU-FPGA version of the system, featuring fault tolerance and real-time scheduling, is a novel contribution that may enable the use of low-cost and fast COTS components in critical real-time environments.

Related repositories:
Hardware (FPGA) project - including custom IPs such as the real-time scheduler and the voters designed in Verilog: https://github.com/HEAPLab/heterogeneousRTOS_HW
HLS project for the fault detector: https://github.com/HEAPLab/heterogeneousRTOS_FaultDetector_HLS
Benchmarks used for the experimental evaluation: https://github.com/HEAPLab/heterogeneousRTOS_benchmark
