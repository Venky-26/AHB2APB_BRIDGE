# AHB2APB_BRIDGE
The AHB to APB bridge is an AHB slave, providing an interface between the high speed AHB and the low-power APB.Read and write transfers on the AHB are converted into equivalent transfers on the APB.As the APB is not piplined, then wait states are added during transfers to and from the APB when the AHB is required to wait for the APB.
