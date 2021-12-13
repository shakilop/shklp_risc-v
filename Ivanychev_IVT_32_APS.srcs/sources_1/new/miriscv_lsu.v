`include "miriscv_defines.v"

module miriscv_lsu (
    input clk_i,// синхронизация 
    input arstn_i,// сброс внутренних регистров
    
    //core protocol
    input [31:0]    lsu_addr_i,         // адрес, по которому хотим обратиться
    input           lsu_we_i,           // 1 - если нужно записать в память
    input [2:0]     lsu_size_i,         // размер обрабатываемых данных
    input [31:0]    lsu_data_i,         // данные для записи в память
    input           lsu_req_i,          // 1 - обратиться к памяти
    output          lsu_stall_req_o,    // используется как !enable pc 
    output [31:0]   lsu_data_o,         // данные считанные из памяти
    
    //memory protocol
    input [31:0]    data_rdata_i,       // запрошенные данные
    output          data_req_o,         // 1 - обратиться к памяти
    output          data_we_o,          // 1 - это запрос на запись
    output [3:0]    data_be_o,          // к каким байтам слова идет обращение
    output [31:0]   data_addr_o,        // адрес, по которому идет обращение
    output [31:0]   data_wdata_o        // данные, которые требуется записать
);

reg lsu_stall_req;
reg [31:0] lsu_data;
reg data_req;
reg data_we;
reg [3:0] data_be;
reg [31:0] data_addr;
reg [31:0] data_wdata;

reg count;

assign lsu_stall_req_o = lsu_stall_req;
assign lsu_data_o = lsu_data;
assign data_req_o = data_req;
assign data_we_o = data_we;
assign data_be_o = data_be;
assign data_addr_o = data_addr;
assign data_wdata_o = data_wdata;

always @(*) begin
    // 1 такт
    if (lsu_req_i && count==0) begin
        lsu_stall_req <= 1;
        data_req <= 1;
        data_addr <= {lsu_addr_i[31:2],2'b00};
        if (lsu_we_i) begin
            //Запись
            data_we <= 1;
            case (lsu_size_i)
                    `LDST_B:  
                        begin 
                            data_wdata <= { 4{lsu_data_i[7:0]} };
                            case (lsu_addr_i[1:0])
                                2'b00: data_be <= 4'b0001;
                                2'b01: data_be <= 4'b0010;
                                2'b10: data_be <= 4'b0100;
                                2'b11: data_be <= 4'b1000;
                            endcase
                        end
                        `LDST_H: 
                        begin 
                            data_wdata <= { 2{lsu_data_i[15:0]}};
                            case (lsu_addr_i[1:0])
                                2'b00: data_be <= 4'b0011;
                                2'b10: data_be <= 4'b1100;
                            endcase
                        end
                    `LDST_W: 
                        begin
                            data_wdata <= lsu_data_i[31:0]; 
                            data_be <= 4'b1111;
                        end
            endcase
        end
        //Чтение
        else begin
            data_we <= 0;
        end      
    end
    //2 такт
    else 
        if (lsu_req_i && count == 1) begin
            lsu_stall_req <= 0;
            data_req <= 0;
            data_we <= 0;
            if (!lsu_we_i) begin
            //Чтение
                case (lsu_size_i)                    
                    `LDST_B:
                        case (lsu_addr_i[1:0])
                            2'b00: lsu_data <= {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                            2'b01: lsu_data <= {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                            2'b10: lsu_data <= {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                            2'b11: lsu_data <= {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                        endcase
                    `LDST_H:
                        case (lsu_addr_i[1:0])
                            2'd00: lsu_data <= {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
                            2'b10: lsu_data <= {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                        endcase
                    `LDST_W:
                        case (lsu_addr_i[1:0])
                            2'd00: lsu_data <= data_rdata_i[31:0];
                        endcase
                    `LDST_BU:
                        case (lsu_addr_i[1:0])
                            2'b0: lsu_data <= {24'b0, data_rdata_i[7:0]};
                            2'b1: lsu_data <= {24'b0, data_rdata_i[15:8]};
                            2'b10: lsu_data <= {24'b0, data_rdata_i[23:16]};
                            2'b11: lsu_data <= {24'b0, data_rdata_i[31:24]};
                        endcase
                    `LDST_HU:
                        case (lsu_addr_i[1:0])
                            2'd00: lsu_data <= {16'b0, data_rdata_i[15:0]};
                            2'b10: lsu_data <= {16'b0, data_rdata_i[31:16]};
                        endcase
                endcase
            end
        end
    
    else begin
        lsu_stall_req <= 0;
        data_req <= 0;
        data_we <= 0;
    end
end

always @(posedge clk_i) begin
    if (arstn_i) begin
        count <= 0;
        lsu_stall_req <= 0;
        lsu_data <= 0;
        data_req <= 0;
        data_we <= 0;
        data_be <= 0;
        data_addr <= 0;
        data_wdata <= 0;
    end
    else begin
        if (lsu_req_i == 1 && count == 0)
            count <= 1;
        else
            count <= 0;
    end
end

//always @(posedge clk_i) begin
//    if (arstn_i) begin
//        lsu_stall_req <= 0;
//        lsu_data <= 0;
//        data_req <= 0;
//        data_we <= 0;
//        data_be <= 0;
//        data_addr <= 0;
//        data_wdata <= 0;
//    end
//    else if (lsu_req_i) begin
//        //Чтение из памяти
//        if (!lsu_we_i) begin
//            //Такт обращения к памяти
//            if (!lsu_stall_req) begin
//                lsu_stall_req <= 1;
//                data_addr <= lsu_addr_i;
//                data_req <= 1;
//            end 
//            else
//            //Такт чтения данных из памяти
//            begin
//                lsu_stall_req <= 0;
//                data_req <= 0;
//                case (lsu_size_i)                    
//                    `LDST_B:
//                        case (lsu_addr_i[1:0])
//                            2'b00: lsu_data <= {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
//                            2'b01: lsu_data <= {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
//                            2'b10: lsu_data <= {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
//                            2'b11: lsu_data <= {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
//                        endcase
//                    `LDST_H:
//                        case (lsu_addr_i[1:0])
//                            2'd00: lsu_data <= {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
//                            2'b10: lsu_data <= {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
//                        endcase
//                    `LDST_W:
//                        case (lsu_addr_i[1:0])
//                            2'd00: lsu_data <= data_rdata_i[31:0];
//                        endcase
//                    `LDST_BU:
//                        case (lsu_addr_i[1:0])
//                            2'b0: lsu_data <= {24'b0, data_rdata_i[7:0]};
//                            2'b1: lsu_data <= {24'b0, data_rdata_i[15:8]};
//                            2'b10: lsu_data <= {24'b0, data_rdata_i[23:16]};
//                            2'b11: lsu_data <= {24'b0, data_rdata_i[31:24]};
//                        endcase
//                    `LDST_HU:
//                        case (lsu_addr_i[1:0])
//                            2'd00: lsu_data <= {16'b0, data_rdata_i[15:0]};
//                            2'b10: lsu_data <= {16'b0, data_rdata_i[31:16]};
//                        endcase
//                endcase
//            end
//        end
//        //Запись в память
//        else begin
//            //Такт обращения к памяти
//            if (!lsu_stall_req) begin
//                lsu_stall_req <= 1;
//                data_req <= 1;
//                data_we <= 1;
//                data_addr <= {lsu_addr_i[31:2],2'd0};
//                case (lsu_size_i)
//                    `LDST_B:  
//                        begin 
//                            data_wdata <= { 4{lsu_data_i[7:0]} };
//                            case (lsu_addr_i[1:0])
//                                2'b00: data_be <= 4'b0001;
//                                2'b01: data_be <= 4'b0010;
//                                2'b10: data_be <= 4'b0100;
//                                2'b11: data_be <= 4'b1000;
//                            endcase
//                        end
//                    `LDST_H: 
//                        begin 
//                            data_wdata <= { 2{lsu_data_i[15:0]}};
//                            case (lsu_addr_i[1:0])
//                                2'b00: data_be <= 4'b0011;
//                                2'b10: data_be <= 4'b1100;
//                            endcase
//                        end
//                    `LDST_W: 
//                        begin
//                            data_wdata <= lsu_data_i[31:0]; 
//                            data_be <= 4'b1111;
//                        end
//                endcase
                
//            end
//            else
//                lsu_stall_req <= 0;
//        end
        
//    end
//end



endmodule