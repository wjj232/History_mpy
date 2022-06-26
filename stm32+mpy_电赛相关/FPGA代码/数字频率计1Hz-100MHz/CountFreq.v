`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/27 15:15:42
// Design Name: 
// Module Name: CountFreq
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CountFreq(
    input clk_in_100MHz,      // ����100MHzʱ��
    input sig_in,             // �����źŵ�TTL��ƽ   
    input m_gdata_ready,      // ��Ƭ�ɽ����źţ���������Ϊ��  ��ʹ�ü�����ȫ�����㲻����
    input enable,             // ʹ�ܶ�   �ߵ�ƽ��Ч   ���͵�ƽ   ��ȫ�����㲻����   �ٴθߵ�ƽ������
    input rst_n,              // �첽��λ�ź�
    
    output reg [31:0] clk_num,    // ���ʱ�Ӽ�����Ŀ
    output reg [31:0] sig_num,    // ����źż�����Ŀ
    output reg out_valid          // �����ߵ�ƽ�������Ч�������Ч��  ���ֵ���治�ټ���
    );
    initial begin
        clk_num = 32'd0;
        sig_num = 32'd0;
        out_valid = 0;
    end
    // �������Ĺ���ʹ�ܶ��ɿ��ƶ���ready�˹�ͬ����
    // ����ǰ����ģʽ��ѡ��  ������Ƭ�ɽ�������ʱ�ſɹ���   ����������ȴ�
    wire enable_count;
    and a1(enable_count, enable, m_gdata_ready);
    // �����ʼ��������������ź� sig_in ��������
    // ����ʱ��������� 1ms ��100 000 ��ʱ������
    reg sig_in_posedge; // ���ڼ�¼�����ź������صĵ���
    initial sig_in_posedge = 1'b0; // ��ʼһ��Ϊ0

    //wire enable_count_sig_in;
    //and a2(enable_count_sig_in, enable_count); // Ϊ�˱�����ʱ  �Ǿ�������
    wire [31:0] sig_num_wire;
    //�����Ƽӷ��� IP�� vivado
    counter count_sig_in (
      .CLK(sig_in),  // input wire CLK
      .CE(enable_count),    // input wire CE
      .SCLR(out_valid),  // input wire SCLR
      .Q(sig_num_wire)      // output wire [31 : 0] Q
    );
    
    wire enable_count_clk;
    and a3(enable_count_clk, enable_count, sig_in_posedge);
    wire [31:0] clk_num_wire;
    //�����Ƽӷ��� IP�� vivado
    counter count_clk (
      .CLK(clk_in_100MHz),  // input wire CLK
      .CE(enable_count_clk),    // input wire CE
      .SCLR(out_valid),  // input wire SCLR
      .Q(clk_num_wire)      // output wire [31 : 0] Q
    );
    reg assign_flag; // ��ֵ��ǩ  
    initial assign_flag = 1;
    always @(posedge sig_in)
        begin
            if (enable_count == 0)
                out_valid <= 0; // ready = 0 ��ʱ�� �������Ч��
                assign_flag <= 1; // ���ܹ�����ʱ�� ������ֵΪ0
                
            if (enable_count == 1 && assign_flag)
                sig_in_posedge <= 1'b1; // һ��Ҫ����ʽ  ���������غ�ͱ���й�������
            if (sig_num_wire > 0 && clk_num_wire > 32'd100000 && assign_flag)
            // ������־  
                begin
                    clk_num <= clk_num_wire; 
                    sig_num <= sig_num_wire;
                    out_valid <= 1;
                    sig_in_posedge <= 1'b0; // ���ܹ���ʱ  ����������Ϊ0
                    assign_flag <= 0; // һ�ι���ֻ�ܸ�ֵһ��
                end
            if (out_valid)
                assign_flag <= 0;

        end 
     
endmodule
