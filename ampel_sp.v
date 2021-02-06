module ampel_sp(
  input clk,
  input reset,
  input hs_f_an,
  input ns_f_an,
  input ready,
  input [4:0] count,
  output reg hs_rt,
  output reg hs_ge,
  output reg hs_gr,
  output reg ns_rt,
  output reg ns_ge,
  output reg ns_gr,
  output reg hs_f_sg,
  output reg hs_f_rt,
  output reg hs_f_gr,
  output reg ns_f_sg,
  output reg ns_f_rt,
  output reg ns_f_gr,
  output reg load,
  output reg [4:0] init
  );

  //vllt kann man einige Setups weglassen
  parameter HS_RGelb_Setup    = 5'd0,
            HS_RGelb_NS_Rot   = 5'd1,
            HS_Gruen_Setup    = 5'd2,
            HS_Gruen_NS_Rot   = 5'd3,
            HS_Gelb_Setup     = 5'd4,
            HS_Gelb_NS_Rot    = 5'd5,
            HS_Rot_Setup      = 5'd6,
            HS_Rot_NS_Rot     = 5'd7,
            NS_RGelb_Setup    = 5'd8,
            NS_RGelb_HS_Rot   = 5'd9,
            NS_Gruen_Setup    = 5'd10,
            NS_Gruen_HS_Rot   = 5'd11,
            NS_Gelb_Setup     = 5'd12,
            NS_Gelb_HS_Rot    = 5'd13,
            NS_Rot_Setup      = 5'd14,
            NS_Rot_HS_Rot     = 5'd15,
            HS_F_Setup        = 5'd16,
            HS_F              = 5'd17,
            NS_F_Setup        = 5'd18,
            NS_F              = 5'd19;


  reg [4:0] state;
  reg [4:0] nextstate;

  //synchroner Teil
  always @ ( posedge clk ) begin
    if(reset)
      state <= NS_Rot_Setup;
      //vllt schon nextstate initialisieren?
    else
      state <= nextstate;
  end

  //FSM
  always @ ( * ) begin
    case(state)

      //Hauptzyklus
      HS_RGelb_Setup: begin nextstate <= HS_RGelb_NS_Rot; end
      HS_RGelb_NS_Rot: begin
                        if(ready) nextstate <= HS_Gruen_Setup;
                        else nextstate <= HS_RGelb_NS_Rot;
                       end
      HS_Gruen_Setup: begin nextstate <= HS_Gruen_NS_Rot; end
      HS_Gruen_NS_Rot: begin
                        if(ready) nextstate <= HS_Gelb_Setup;
                        else if(hs_f_an) begin
                                            if(count > 5) nextstate <= HS_F_Setup;
                                            else nextstate <= HS_F;
                                         end
                        else nextstate <= HS_Gruen_NS_Rot;
                       end
      HS_Gelb_Setup: begin nextstate <= HS_Gelb_NS_Rot; end
      HS_Gelb_NS_Rot: begin
                          if(ready) nextstate <= HS_Rot_Setup;
                          else nextstate <= HS_Gelb_NS_Rot;
                      end
      HS_Rot_Setup: begin nextstate <= HS_Rot_NS_Rot; end
      HS_Rot_NS_Rot: begin
                        if(ready) nextstate <= NS_RGelb_Setup;
                        else nextstate <= HS_Rot_NS_Rot;
                     end
      NS_RGelb_Setup: begin nextstate <= NS_RGelb_HS_Rot; end
      NS_RGelb_HS_Rot: begin
                        if(ready) nextstate <= NS_Gruen_Setup;
                        else nextstate <= NS_RGelb_HS_Rot;
                       end
      NS_Gruen_Setup: begin nextstate <= NS_Gruen_HS_Rot; end
      NS_Gruen_HS_Rot: begin
                        if(ready) nextstate <= NS_Gelb_Setup;
                        else if(ns_f_an) begin
                                          if(count > 5) nextstate <= NS_F_Setup;
                                          else nextstate <= NS_F;
                                         end
                       else nextstate <= NS_Gruen_HS_Rot;
                     end
      NS_Gelb_Setup: begin nextstate <= NS_Gelb_HS_Rot; end
      NS_Gelb_HS_Rot: begin
                       if(ready) nextstate <= NS_Rot_Setup;
                       else nextstate <= NS_Gelb_HS_Rot;
                      end
      NS_Rot_Setup: begin nextstate <= NS_Rot_HS_Rot; end
      NS_Rot_HS_Rot: begin
                       if(ready) nextstate <= HS_RGelb_Setup;
                       else nextstate <= NS_Rot_HS_Rot;
                     end

      //Fussgaenger Zustände
      HS_F_Setup: begin nextstate <= HS_F; end
      HS_F: begin
              if(ready) nextstate <= HS_Gelb_Setup;
              else nextstate <= HS_F;
            end
      NS_F_Setup: begin nextstate <= NS_F; end
      NS_F: begin
              if(ready) nextstate <= NS_Gelb_Setup;
              else nextstate <= NS_F;
            end
    endcase
  end

//Ausgänge
always @ ( * ) begin
  case(state)

    //Hauptzyklus
    NS_Gelb_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 1;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    NS_Gelb_HS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 1;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    NS_Rot_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    NS_Rot_HS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    HS_RGelb_Setup: begin
      hs_rt <= 1;
      hs_ge <= 1;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    HS_RGelb_NS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 1;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    HS_Gruen_Setup: begin
      hs_rt <= 0;
      hs_ge <= 0;
      hs_gr <= 1;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 0;
      ns_f_gr <= 1;
      load <= 1;
      init <= 5'd15;
    end

    HS_Gruen_NS_Rot: begin
      hs_rt <= 0;
      hs_ge <= 0;
      hs_gr <= 1;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 0;
      ns_f_gr <= 1;
      load <= 0;
      init <= 5'd0;
    end

    HS_Gelb_Setup: begin
      hs_rt <= 0;
      hs_ge <= 1;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    HS_Gelb_NS_Rot: begin
      hs_rt <= 0;
      hs_ge <= 1;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    HS_Rot_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    HS_Rot_NS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    NS_RGelb_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 1;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd1;
    end

    NS_RGelb_HS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 1;
      ns_ge <= 1;
      ns_gr <= 0;
      hs_f_sg <= 0;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    NS_Gruen_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 0;
      ns_gr <= 1;
      hs_f_sg <= 0;
      hs_f_rt <= 0;
      hs_f_gr <= 1;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd15;
    end

    NS_Gruen_HS_Rot: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 0;
      ns_gr <= 1;
      hs_f_sg <= 0;
      hs_f_rt <= 0;
      hs_f_gr <= 1;
      ns_f_sg <= 0;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

    //Fussgaenger Zustände
    HS_F_Setup: begin
      hs_rt <= 0;
      hs_ge <= 0;
      hs_gr <= 1;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 1;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 0;
      ns_f_gr <= 1;
      load <= 1;
      init <= 5'd5;
    end

    HS_F: begin
      hs_rt <= 0;
      hs_ge <= 0;
      hs_gr <= 1;
      ns_rt <= 1;
      ns_ge <= 0;
      ns_gr <= 0;
      hs_f_sg <= 1;
      hs_f_rt <= 1;
      hs_f_gr <= 0;
      ns_f_sg <= 0;
      ns_f_rt <= 0;
      ns_f_gr <= 1;
      load <= 0;
      init <= 5'd0;
    end


    NS_F_Setup: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 0;
      ns_gr <= 1;
      hs_f_sg <= 0;
      hs_f_rt <= 0;
      hs_f_gr <= 1;
      ns_f_sg <= 1;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 1;
      init <= 5'd5;
    end

    NS_F: begin
      hs_rt <= 1;
      hs_ge <= 0;
      hs_gr <= 0;
      ns_rt <= 0;
      ns_ge <= 0;
      ns_gr <= 1;
      hs_f_sg <= 0;
      hs_f_rt <= 0;
      hs_f_gr <= 1;
      ns_f_sg <= 1;
      ns_f_rt <= 1;
      ns_f_gr <= 0;
      load <= 0;
      init <= 5'd0;
    end

  endcase
end
endmodule
