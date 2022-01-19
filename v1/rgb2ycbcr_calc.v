/////////////////////////////////////////////////////////////////////
////                                                             ////
////  RGB to YCrCb Color Space converter                         ////
////                                                             ////
////Y = 0.257R¡ä + 0.504G¡ä + 0.098B¡ä + 16
////
////Cb = -0.148R¡ä - 0.291G¡ä + 0.439B¡ä + 128
////
////Cr = 0.439R¡ä - 0.368G¡ä - 0.071B¡ä + 128                     ////
////                                                             ////
////  Author: Cloud Yu                                           ////
////          ymjcloud@163.com                                   ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Cloud                                    ////
////                    ymjcloud@163.com                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////



`timescale 1ns/10ps

module rgb2ycbcr_calc(clk, r, g, b, y, cr, cb);
	//
	// inputs & outputs
	//
	input        clk;
	input  [7:0] r, g, b;
	output [7:0] y = 0, cr = 0, cb = 0;

	parameter const1 = 10'h107;	//0.257
	parameter const2 = 10'h204;	//0.504
	parameter const3 = 10'h64;	//0.098
	
	parameter const4 = 10'h97;	//0.148
	parameter const5 = 10'h129;	//0.291
	parameter const6 = 10'h1c1;	//0.439
	
	parameter const7 = 10'h1c1;	//0.439
	parameter const8 = 10'h178;	//0.368
	parameter const9 = 10'h48;	//0.071


	// step 1: Calculate Y, Cr, Cb
	//*4 for 10-bits precision
	//Y = 0.257R¡ä + 0.504G¡ä + 0.098B¡ä + 16
	//
	//Cb = -0.148R¡ä - 0.291G¡ä + 0.439B¡ä + 128
	//
	//Cr = 0.439R¡ä - 0.368G¡ä - 0.071B¡ä + 128	
	//
	// variables
	//
	reg [7:0] y, cr, cb;
	// calculate Yint,Cb_int,Cr_int
	reg [20:0] Y_int = 0, Cb_int = 0, Cr_int = 0;

    always@(posedge clk)
    begin
        Y_int  <= const1*r + const2*g + const3*b + 18'h4000;
        Cb_int <= 18'h20000 + const6*b - const4*r - const5*g;
        Cr_int <= 18'h20000 + const7*r - const8*g - const9*b;
    end

	/* limit output to 0 - 4095, <0 equals o and >4095 equals 4095 */
    always@(posedge clk)
    begin
        y  <=  (Y_int[20]) ? 16 : (Y_int[19:18] == 2'b0)  ? Y_int[17:10]  : 235;
        cb <= (Cb_int[20]) ? 16 : (Cb_int[19:18] == 2'b0) ? Cb_int[17:10] : 240;
        cr <= (Cr_int[20]) ? 16 : (Cr_int[19:18] == 2'b0) ? Cr_int[17:10] : 240;
    end
    
endmodule
