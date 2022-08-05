
`timescale 1 ns / 1 ps

	module scheduler_v1_0_S_AXI #
	(
    // Users to add parameters here
    parameter maxTasks = 128,

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 14,
    // Number of Interrupts
    parameter integer C_NUM_OF_INTR	= 1,
    // Each bit corresponds to Sensitivity of interrupt :  0 - EDGE, 1 - LEVEL
    parameter  C_INTR_SENSITIVITY	= 32'hFFFFFFFF,
    // Each bit corresponds to Sub-type of INTR: [0 - FALLING_EDGE, 1 - RISING_EDGE : if C_INTR_SENSITIVITY is EDGE(0)] and [ 0 - LEVEL_LOW, 1 - LEVEL_LOW : if C_INTR_SENSITIVITY is LEVEL(1) ]
    parameter  C_INTR_ACTIVE_STATE	= 32'hFFFFFFFF,
    // Sensitivity of IRQ: 0 - EDGE, 1 - LEVEL
    parameter integer C_IRQ_SENSITIVITY	= 1,
    // Sub-type of IRQ: [0 - FALLING_EDGE, 1 - RISING_EDGE : if C_IRQ_SENSITIVITY is EDGE(0)] and [ 0 - LEVEL_LOW, 1 - LEVEL_LOW : if C_IRQ_SENSITIVITY is LEVEL(1) ]
    parameter integer C_IRQ_ACTIVE_STATE	= 1
)
	(
    // Users to add ports here

    input wire taskWriteDone,
    input wire taskWriteStarted,
    output reg taskReady,
    output reg [31:0] taskPtr,

    output reg uninitializedLed,
    output reg readyLed,
    output reg runningLed,

    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5,

    //    output reg invalidControlLed,
    //    output reg invalidAddressLed,

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire  S_AXI_RREADY,
    // interrupt out port
    output wire  irq
);

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
    reg  	axi_awready;
    reg  	axi_wready;
    reg [1 : 0] 	axi_bresp;
    reg  	axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
    reg  	axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
    reg [1 : 0] 	axi_rresp;
    reg  	axi_rvalid;

    //------------------------------------------------
    //-- Signals for Interrupt register space 
    //------------------------------------------------
    //-- Number of Slave Registers 5
    reg [0 : 0] reg_global_intr_en;
    reg [C_NUM_OF_INTR-1 :0] reg_intr_en;
    reg [C_NUM_OF_INTR-1 :0] reg_intr_sts;
    reg [C_NUM_OF_INTR-1 :0] reg_intr_ack;
    reg [C_NUM_OF_INTR-1 :0] reg_intr_pending;
    reg [C_NUM_OF_INTR-1 :0] intr;
    reg [C_NUM_OF_INTR-1 :0] det_intr;
    wire slv_reg_rden;
    wire slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
    reg [3:0]	intr_counter;
    genvar i;
    integer j;
    reg intr_all;
    reg intr_ack_all;
    wire s_irq;
    reg intr_all_ff;
    reg intr_ack_all_ff;
    reg aw_en;
    //_____________________________________
    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    //-1 wrt real one
    localparam integer OPT_MEM_ADDR_BITS = 11;
    //----------------------------------------------
    /* //-- Signals for user logic register space example*/
    //------------------------------------------------
    //-- Number of Slave Registers 8

    reg [C_S_AXI_DATA_WIDTH-1:0]	slv_control_reg;
    reg new_slv_control_reg;
    localparam[(C_S_AXI_DATA_WIDTH/2)-1:0] control_startScheduler=1, control_stopScheduler=2, control_resumeTask=3, control_taskEnded=4, control_taskSuspended=5, control_jobEnded=6;
    //    localparam[(C_S_AXI_DATA_WIDTH/2)-1:0] control_setTaskNum = C_S_AXI_DATA_WIDTH/2'd1, control_startScheduler=C_S_AXI_DATA_WIDTH/2'd2, control_startTask=C_S_AXI_DATA_WIDTH/2'd3, control_suspendTask=C_S_AXI_DATA_WIDTH/2'd4;

    //FSM status reg
    reg [3:0]	slv_status_reg;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_number_of_tasks_reg;
    //FSM states encoding
    localparam[2:0] state_uninitialized=3'd1, state_ready=3'd2, state_running=3'd3, state_stopped=3'd4;

    localparam RTTask_tSizeInWords=5;

    localparam [OPT_MEM_ADDR_BITS:0] maxRTListAddr=(maxTasks*RTTask_tSizeInWords);

    localparam [OPT_MEM_ADDR_BITS:0] maxRQNumAddr=maxRTListAddr+maxTasks;
    localparam [OPT_MEM_ADDR_BITS:0] maxAQNumAddr=maxRQNumAddr+maxTasks;

    localparam [OPT_MEM_ADDR_BITS:0] maxRQDLAddr=maxAQNumAddr+maxTasks;
    localparam [OPT_MEM_ADDR_BITS:0] maxRQActAddr=maxRQDLAddr+maxTasks;

    reg[C_S_AXI_DATA_WIDTH:0] tasksList [(maxTasks*RTTask_tSizeInWords)-1:0];
    reg[16:0] readyQNumDLASC [maxTasks-1:0];
    reg[16:0] activationQNumATASC [maxTasks-1:0];
    reg[C_S_AXI_DATA_WIDTH:0] readyQDeadlineDLASC [maxTasks-1:0];
    reg[C_S_AXI_DATA_WIDTH:0] activationQActivationATASC [maxTasks-1:0];

    integer	 byte_index;
    //________________________
    // I/O Connections assignments

    assign S_AXI_AWREADY	= axi_awready;
    assign S_AXI_WREADY	= axi_wready;
    assign S_AXI_BRESP	= axi_bresp;
    assign S_AXI_BVALID	= axi_bvalid;
    assign S_AXI_ARREADY	= axi_arready;
    assign S_AXI_RDATA	= axi_rdata;
    assign S_AXI_RRESP	= axi_rresp;
    assign S_AXI_RVALID	= axi_rvalid;
    // Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_awready <= 1'b0;
                aw_en <= 1'b1;
            end
        else
            begin
                if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
                    begin
                        // slave is ready to accept write address when 
                        // there is a valid write address and write data
                        // on the write address and data bus. This design 
                        // expects no outstanding transactions. 
                        axi_awready <= 1'b1;
                        aw_en <= 1'b0;
                    end
                else if (S_AXI_BREADY && axi_bvalid)
                    begin
                        aw_en <= 1'b1;
                        axi_awready <= 1'b0;
                    end
                else
                    begin
                        axi_awready <= 1'b0;
                    end
            end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both 
    // S_AXI_AWVALID and S_AXI_WVALID are valid. 

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_awaddr <= 0;
            end
        else
            begin
                if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
                begin
                    // Write Address latching 
                    axi_awaddr <= S_AXI_AWADDR;
                end
            end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    // de-asserted when reset is low. 

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_wready <= 1'b0;
            end
        else
            begin
                if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en)
                    begin
                        // slave is ready to accept write data when 
                        // there is a valid write address and write data
                        // on the write address and data bus. This design 
                        // expects no outstanding transactions. 
                        axi_wready <= 1'b1;
                    end
                else
                    begin
                        axi_wready <= 1'b0;
                    end
            end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    generate
        for(i=0; i<= C_NUM_OF_INTR-1; i=i+1)
        begin : gen_intr_reg

            // Global interrupt enable register                            
            always @( posedge S_AXI_ACLK )
            begin
                if ( S_AXI_ARESETN == 1'b0)
                    begin
                        reg_global_intr_en[0] <= 1'b0;
                    end
                else if (slv_reg_wren && axi_awaddr[4:2] == 3'h0)
                begin
                    reg_global_intr_en[0] <= S_AXI_WDATA[0];
                end
            end

            // Interrupt enable register                                   
            always @( posedge S_AXI_ACLK )
            begin
                if ( S_AXI_ARESETN == 1'b0)
                    begin
                        reg_intr_en[i] <= 1'b0;
                    end
                else if (slv_reg_wren && axi_awaddr[4:2] == 3'h1)
                begin
                    reg_intr_en[i] <= S_AXI_WDATA[i];
                end
            end

            // Interrupt status register                                      
            always @( posedge S_AXI_ACLK )
            begin
                if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[i] == 1'b1)
                    begin
                        reg_intr_sts[i] <= 1'b0;
                    end
                else
                    begin
                        reg_intr_sts[i] <= det_intr[i];
                    end
            end

            // Interrupt acknowledgement register                            
            always @( posedge S_AXI_ACLK )
            begin
                if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[i] == 1'b1)
                    begin
                        reg_intr_ack[i] <= 1'b0;
                    end
                else if (slv_reg_wren && axi_awaddr[4:2] == 3'h3)
                begin
                    reg_intr_ack[i] <= S_AXI_WDATA[i];
                end
            end

            // Interrupt pending register                                    
            always @( posedge S_AXI_ACLK )
            begin
                if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[i] == 1'b1)
                    begin
                        reg_intr_pending[i] <= 1'b0;
                    end
                else
                    begin
                        reg_intr_pending[i] <= reg_intr_sts[i] & reg_intr_en[i];
                    end
            end

        end
    endgenerate

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    localparam [OPT_MEM_ADDR_BITS:0] tasksOffset= 8;
    //    wire [OPT_MEM_ADDR_BITS:0] addrInWords;
    //    assign addrInWords=axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset;
    reg taskSetWritten;
    reg DLqIndexWritten;
    reg ACTqIndexWritten;
    reg DLqWritten;
    reg ACTqWritten;

    assign led1=taskSetWritten;
    assign led2=DLqIndexWritten;
    assign led3=ACTqIndexWritten;
    assign led4=DLqWritten;
    assign led5=ACTqWritten;

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                slv_control_reg <= 0;
                slv_number_of_tasks_reg<=0;
                new_slv_control_reg <= 1'b0;

                taskSetWritten<=1'b0;
                DLqIndexWritten<=1'b0;
                ACTqIndexWritten<=1'b0;
                DLqWritten<=1'b0;
                ACTqWritten<=1'b0;
            end
        else begin
            if (slv_reg_wren)
                begin
                    if (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] < tasksOffset)
                        begin
                            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                                3'h5:
                                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                                    if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                        // Respective byte enables are asserted as per write strobes 
                                        // Slave register 5
                                        slv_control_reg[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];

                                        new_slv_control_reg <= 1'b1;
                                    end
                                    //                                3'h6:
                                    //                                begin
                                    //                                    slv_control_reg <= slv_control_reg;
                                    //                                    //slv_status_reg <= slv_status_reg;

                                    //                                    new_slv_control_reg <= 1'b0;
                                    //                                    /*for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                                    //                            if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                    //                                // Respective byte enables are asserted as per write strobes 
                                    //                                // Slave register 6
                                    //                                slv_status_reg[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                                    //                                new_slv_control_reg <= 0;

                                    //                            end*/
                                    //                                end
                                3'h7:
                                if (slv_status_reg == state_uninitialized)
                                begin
                                    for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                                        if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                            // Respective byte enables are asserted as per write strobes 
                                            // Slave register 5
                                            slv_number_of_tasks_reg[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];

                                            new_slv_control_reg <= 1'b0;
                                        end
                                end
                                default : begin
                                    //slv_control_reg <= slv_control_reg;
                                    //slv_status_reg <= slv_status_reg;

                                    new_slv_control_reg <= 1'b0;
                                end
                            endcase
                        end
                    else
                        begin
                            new_slv_control_reg <= 1'b0;

                            if (slv_status_reg == state_uninitialized)
                            begin
                                if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRTListAddr)
                                    tasksList[(axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)] <= S_AXI_WDATA;
                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQNumAddr)
                                    readyQNumDLASC[(axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRTListAddr]<= S_AXI_WDATA[15:0];
                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxAQNumAddr)
                                    activationQNumATASC[(axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRQNumAddr]<= S_AXI_WDATA[15:0];
                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQDLAddr)
                                    readyQDeadlineDLASC[(axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxAQNumAddr]<= S_AXI_WDATA;
                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQActAddr)
                                    activationQActivationATASC[(axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRQDLAddr]<= S_AXI_WDATA;

                                    //                                if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)==(maxRTListAddr-1))
                                    //                                    taskSetWritten<=1'b1;
                                    //                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)==(maxRQNumAddr-1))
                                    //                                    DLqIndexWritten<=1'b1;
                                    //                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)==(maxAQNumAddr-1))
                                    //                                    ACTqIndexWritten<=1'b1;
                                    //                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)==(maxRQDLAddr-1))
                                    //                                    DLqWritten<=1'b1;
                                    //                                else if ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)==(maxRQActAddr-1))
                                    //                                    ACTqWritten<=1'b1;

                                case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)
                                    (maxRTListAddr-1):
                                    taskSetWritten<=1'b1;

                                    (maxRQNumAddr-1):
                                    DLqIndexWritten<=1'b1;

                                    (maxAQNumAddr-1):
                                    ACTqIndexWritten<=1'b1;

                                    (maxRQDLAddr-1):
                                    DLqWritten<=1'b1;

                                    (maxRQActAddr-1):
                                    ACTqWritten<=1'b1;
                                endcase
                            end
                        end
                end
            else
                new_slv_control_reg <= 1'b0;
        end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_bvalid  <= 0;
                axi_bresp   <= 2'b0;
            end
        else
            begin
                if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
                    begin
                        // indicates a valid write response is available
                        axi_bvalid <= 1'b1;
                        axi_bresp  <= 2'b0; // 'OKAY' response 
                    end // work error responses in future
                else
                    begin
                        if (S_AXI_BREADY && axi_bvalid)
                        //check if bready is asserted while bvalid is high) 
                        //(there is a possibility that bready is always asserted high)   
                        begin
                            axi_bvalid <= 1'b0;
                        end
                    end
            end
    end

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when S_AXI_ARVALID is 
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_arready <= 1'b0;
                axi_araddr  <= 32'b0;
            end
        else
            begin
                if (~axi_arready && S_AXI_ARVALID)
                    begin
                        // indicates that the slave has acceped the valid read address
                        axi_arready <= 1'b1;
                        // Read address latching
                        axi_araddr  <= S_AXI_ARADDR;
                    end
                else
                    begin
                        axi_arready <= 1'b0;
                    end
            end
    end

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_rvalid <= 0;
                axi_rresp  <= 0;
            end
        else
            begin
                if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
                    begin
                        // Valid read data is available at the read data bus
                        axi_rvalid <= 1'b1;
                        axi_rresp  <= 2'b0; // 'OKAY' response
                    end
                else if (axi_rvalid && S_AXI_RREADY)
                begin
                    // Read data is accepted by the master
                    axi_rvalid <= 1'b0;
                end
            end
    end

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*)
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                reg_data_out <= 0;
            end
        else
            begin
                if (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] < tasksOffset)
                    begin
                        // Address decoding for reading registers
                        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                            3'h0   : reg_data_out <= reg_global_intr_en;
                            3'h1   : reg_data_out <= reg_intr_en;
                            3'h2   : reg_data_out <= reg_intr_sts;
                            3'h3   : reg_data_out <= reg_intr_ack;
                            3'h4   : reg_data_out <= reg_intr_pending;
                            3'h5   : reg_data_out <= slv_control_reg;
                            3'h6   : reg_data_out <= slv_status_reg;
                            3'h7   : reg_data_out <= slv_number_of_tasks_reg;
                            default :
                            begin
                                reg_data_out <= 0;
                            end
                        endcase
                    end
                else
                    begin
                        if ((axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRTListAddr)
                            reg_data_out <= tasksList[(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)];
                        else if ((axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQNumAddr)
                            reg_data_out <= readyQNumDLASC[(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRTListAddr];
                        else if ((axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxAQNumAddr)
                            reg_data_out <= activationQNumATASC[(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRQNumAddr];
                        else if ((axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQDLAddr)
                            reg_data_out <= readyQDeadlineDLASC[(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxAQNumAddr];
                        else if ((axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)<maxRQActAddr)
                            reg_data_out <= activationQActivationATASC[(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]-tasksOffset)-maxRQDLAddr];
                        else
                            reg_data_out <= 32'd0;
                    end
            end
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            begin
                axi_rdata  <= 0;
            end
        else
            begin
                // When there is a valid read address (S_AXI_ARVALID) with 
                // acceptance of read address by the slave (axi_arready), 
                // output the read dada 
                if (slv_reg_rden)
                begin
                    axi_rdata <= reg_data_out; // register read data
                end
            end
    end

    //----------------------------------------------------
    //Example code to generate user logic interrupts
    //Note: The example code presented here is to show you one way of generating
    //      interrupts from the user logic. This code snippet generates a level
    //      triggered interrupt when the intr_counter_reg counts down to zero.
    //----------------------------------------------------

    // Count down counter implementation  


    //	always @ ( posedge S_AXI_ACLK )                                          
    //	begin                                                                    
    //	  if ( S_AXI_ARESETN == 1'b0 )                                           
    //	    begin                                                                
    //	      intr_counter[3:0] <= 4'hF;                                         
    //	    end                                                                  
    //	  else if (intr_counter [3:0] != 4'h0 )                                  
    //	    begin                                                                
    //	      intr_counter[3:0] <= intr_counter[3:0] - 1;                        
    //	    end                                                                  
    //	end                                                                      

    reg oldTaskWriteDone;
    always @ ( posedge S_AXI_ACLK )
    begin
        oldTaskWriteDone <= 0;
        if ( S_AXI_ARESETN == 1'b0)
            begin
                intr <= {C_NUM_OF_INTR{1'b0}};
                oldTaskWriteDone <= 0;
            end
        else
            begin

                oldTaskWriteDone <= taskWriteDone;
                if (taskWriteDone && !oldTaskWriteDone)
                    intr <= {C_NUM_OF_INTR{1'b1}};
                else
                    begin
                        intr <= {C_NUM_OF_INTR{1'b0}};
                    end
            end
            //            begin
            //                if (intr_counter[3:0] == 10)
            //                    begin
            //                        intr <= {C_NUM_OF_INTR{1'b1}};
            //                    end
            //                else
            //                    begin
            //                        intr <= {C_NUM_OF_INTR{1'b0}};
            //                    end
            //            end
    end

    // detects interrupt in any intr input                             
    always @ ( posedge S_AXI_ACLK)
    begin
        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all_ff == 1'b1)
            begin
                intr_all <= 1'b0;
            end
        else
            begin
                intr_all <= |reg_intr_pending;
            end
    end

    // detects intr ack in any reg_intr_ack reg bits                     
    always @ ( posedge S_AXI_ACLK)
    begin
        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all_ff==1'b1)
            begin
                intr_ack_all <= 1'b0;
            end
        else
            begin
                intr_ack_all <= |reg_intr_ack;
            end
    end


    // detects interrupt in any intr input                                  
    always @ ( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0)
            begin
                intr_ack_all_ff <= 1'b0;
                intr_all_ff <= 1'b0;
            end
        else
            begin
                intr_ack_all_ff <= intr_ack_all;
                intr_all_ff <= intr_all;
            end
    end

    //---------------------------------------------------------------------  
    // Hardware interrupt detection                                          
    //---------------------------------------------------------------------  

    // detect interrupts for user selected number of interrupts              

    generate
        for(i=0; i<= C_NUM_OF_INTR-1; i=i+1)
        begin : gen_intr_detection

            if (C_INTR_SENSITIVITY[i] == 1'b1)
            begin: gen_intr_level_detect

                if (C_INTR_ACTIVE_STATE[i] == 1'b1)
                begin: gen_intr_active_high_detect

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
                            begin
                                det_intr[i] <= 1'b0;
                            end
                        else
                            begin
                                if (intr[i] == 1'b1)
                                begin
                                    det_intr[i] <= 1'b1;
                                end
                            end
                    end

                end
                else
                begin: gen_intr_active_low_detect

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
                            begin
                                det_intr[i] <= 1'b0;
                            end
                        else
                            begin
                                if (intr[i] == 1'b0)
                                begin
                                    det_intr[i] <= 1'b1;
                                end
                            end
                    end

                end


            end
            else
            begin:gen_intr_edge_detect

                wire [C_NUM_OF_INTR-1 :0] intr_edge;
                reg [C_NUM_OF_INTR-1 :0] intr_ff;
                reg [C_NUM_OF_INTR-1 :0] intr_ff2;

                if (C_INTR_ACTIVE_STATE[i] == 1)
                begin: gen_intr_rising_edge_detect


                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[i] == 1'b1)
                            begin
                                intr_ff[i] <= 1'b0;
                                intr_ff2[i] <= 1'b0;
                            end
                        else
                            begin
                                intr_ff[i] <= intr[i];
                                intr_ff2[i] <= intr_ff[i];
                            end
                    end

                    assign intr_edge[i] = intr_ff[i] && (!intr_ff2);

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
                            begin
                                det_intr[i] <= 1'b0;
                            end
                        else if (intr_edge[i] == 1'b1)
                        begin
                            det_intr[i] <= 1'b1;
                        end
                    end

                end
                else
                begin: gen_intr_falling_edge_detect

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
                            begin
                                intr_ff[i] <= 1'b1;
                                intr_ff2[i] <= 1'b1;
                            end
                        else
                            begin
                                intr_ff[i] <= intr[i];
                                intr_ff2[i] <= intr_ff[i];
                            end
                    end

                    assign intr_edge[i] = intr_ff2[i] && (!intr_ff);

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
                            begin
                                det_intr[i] <= 1'b0;
                            end
                        else if (intr_edge[i] == 1'b1)
                        begin
                            det_intr[i] <= 1'b1;
                        end
                    end


                end

            end

            // IRQ generation logic                                               

            reg s_irq_lvl;

            if (C_IRQ_SENSITIVITY == 1)
            begin: gen_irq_level

                if (C_IRQ_ACTIVE_STATE == 1)
                begin: irq_level_high

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all == 1'b1)
                            begin
                                s_irq_lvl <= 1'b0;
                            end
                        else if (intr_all == 1'b1 && reg_global_intr_en[0] ==1'b1)
                        begin
                            s_irq_lvl <= 1'b1;
                        end
                    end
                    assign s_irq = s_irq_lvl;
                end
                else
                begin:irq_level_low

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all == 1'b1)
                            begin
                                s_irq_lvl <= 1'b1;
                            end
                        else if (intr_all == 1'b1 && reg_global_intr_en[0] ==1'b1)
                        begin
                            s_irq_lvl <= 1'b0;
                        end
                    end
                    assign s_irq = s_irq_lvl;
                end

            end

            else

            begin: gen_irq_edge

                reg s_irq_lvl_ff;

                if (C_IRQ_ACTIVE_STATE == 1)
                begin: irq_rising_edge

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all == 1'b1)
                            begin
                                s_irq_lvl <= 1'b0;
                                s_irq_lvl_ff <= 1'b0;
                            end
                        else if (intr_all == 1'b1 && reg_global_intr_en[0] ==1'b1)
                        begin
                            s_irq_lvl <= 1'b1;
                            s_irq_lvl_ff <= s_irq_lvl;
                        end
                    end

                    assign s_irq =  s_irq_lvl && (!s_irq_lvl_ff);

                end
                else
                begin:irq_falling_edge

                    always @ ( posedge S_AXI_ACLK )
                    begin
                        if ( S_AXI_ARESETN == 1'b0 || intr_ack_all == 1'b1 )
                            begin
                                s_irq_lvl <= 1'b1;
                                s_irq_lvl_ff <= 1'b1;
                            end
                        else if (intr_all == 1'b1 && reg_global_intr_en[0] ==1'b1)
                        begin
                            s_irq_lvl <= 1'b0;
                            s_irq_lvl_ff <= s_irq_lvl;
                        end
                    end

                    assign s_irq =  !(s_irq_lvl_ff && (!s_irq_lvl));

                end
            end

            assign irq = s_irq;

        end
    endgenerate

    // Add user logic here


    //control signals encoding

    reg firstrun;

    always @(posedge S_AXI_ACLK)
    begin
        if ( ! S_AXI_ARESETN ) begin //reset
            firstrun<=1;

            taskPtr<=32'd0;
            taskReady<=0;

            slv_status_reg<=state_uninitialized;
        end
        else begin //not reset

            if (new_slv_control_reg)
            begin
                //new control signal supplied

                //FSM logic which reacts to control signal changes changing states
                case (slv_control_reg[31:16])
                    control_startScheduler:
                    begin
                        if (slv_status_reg==state_ready)
                        begin
                            slv_status_reg<=state_running;
                        end
                    end
                endcase
            end


            case(slv_status_reg)
                state_uninitialized:
                begin
                    if ( taskSetWritten && DLqIndexWritten && ACTqIndexWritten && DLqWritten && ACTqWritten && slv_number_of_tasks_reg!=0 )
                    begin
                        slv_status_reg<=state_ready;
                    end
                 end

                state_running:
                begin
                    if (firstrun)
                        begin
                            taskPtr<=tasksList[1];
                            taskReady<=1;
                            firstrun<=0;
                        end
                    else if(taskReady && taskWriteStarted)
                    begin
                        taskReady<=0;
                        taskPtr<=0;
                    end
                end
            endcase

        end
    end

//    always @*
//    begin
//        if ( S_AXI_ARESETN == 1'b1 && slv_status_reg==state_uninitialized && taskSetWritten && DLqIndexWritten && ACTqIndexWritten && DLqWritten && ACTqWritten ) //&& slv_number_of_tasks_reg!= 0 )
//        begin
//            slv_status_reg<=state_ready;
//        end
//    end

    //FSM logic which reacts to state changes    

    always @(slv_status_reg)
    begin
        case (slv_status_reg)
            state_uninitialized:
            begin
                uninitializedLed<=1;
                readyLed<=0;
                runningLed<=0;
            end
            state_ready:
            begin
                uninitializedLed<=0;
                readyLed<=1;
                runningLed<=0;
            end
            state_running:
            begin
                uninitializedLed<=0;
                readyLed<=0;
                runningLed<=1;
            end
        endcase


    end

    // User logic ends

endmodule