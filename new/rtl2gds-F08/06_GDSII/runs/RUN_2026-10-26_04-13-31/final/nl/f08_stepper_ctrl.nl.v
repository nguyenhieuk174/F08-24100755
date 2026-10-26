module f08_stepper_ctrl (clk,
    dir,
    half_step,
    rst_n,
    run,
    coil,
    speed_div,
    state_dbg);
 input clk;
 input dir;
 input half_step;
 input rst_n;
 input run;
 output [3:0] coil;
 input [7:0] speed_div;
 output [2:0] state_dbg;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire _077_;
 wire _078_;
 wire _079_;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net1;
 wire \div_count[0] ;
 wire \div_count[1] ;
 wire \div_count[2] ;
 wire \div_count[3] ;
 wire \div_count[4] ;
 wire \div_count[5] ;
 wire \div_count[6] ;
 wire \div_count[7] ;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net17;
 wire net18;
 wire net19;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;

 sky130_fd_sc_hd__decap_3 FILLER_0_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_103 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_106 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_40 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_43 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_97 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_44 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_47 ();
 sky130_fd_sc_hd__fill_2 FILLER_10_82 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_51 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_83 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_86 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_46 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_49 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_52 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_58 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_61 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_64 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_67 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_70 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_80 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_9 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_99 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_12 ();
 sky130_fd_sc_hd__fill_2 FILLER_13_22 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_67 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_70 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_76 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_79 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_82 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_104 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_107 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_42 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_64 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_67 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_93 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_96 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_22 ();
 sky130_fd_sc_hd__fill_2 FILLER_15_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_53 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_56 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_60 ();
 sky130_fd_sc_hd__fill_2 FILLER_16_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_77 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_96 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_99 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_35 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_55 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_76 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_79 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_89 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_42 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_66 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_18 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_71 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_87 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_90 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_103 ();
 sky130_fd_sc_hd__fill_2 FILLER_4_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_56 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_59 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_65 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_71 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_80 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_105 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_22 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_25 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_28 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_34 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_40 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_43 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_46 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_49 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_69 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_87 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_96 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_99 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_16 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_44 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_65 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_71 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_74 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_77 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_57 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_104 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_107 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_13 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_16 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_38 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_6 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_75 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_82 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_103 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_24 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_30 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_33 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_39 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_60 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_87 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_97 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_28 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_29 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_30 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Left_31 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Right_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Left_32 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Right_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Left_33 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Right_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Left_34 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Right_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Left_35 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Right_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_26 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_27 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_36 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_52 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_53 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_54 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_55 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_56 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_57 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_58 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_59 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_60 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_61 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_62 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_63 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_64 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_65 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_40 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_41 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_42 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_43 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_44 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_45 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_46 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_47 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_48 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_49 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_50 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_51 ();
 sky130_fd_sc_hd__inv_2 _080_ (.A(\div_count[1] ),
    .Y(_033_));
 sky130_fd_sc_hd__inv_2 _081_ (.A(net4),
    .Y(_034_));
 sky130_fd_sc_hd__inv_2 _082_ (.A(net2),
    .Y(_035_));
 sky130_fd_sc_hd__inv_2 _083_ (.A(_002_),
    .Y(_036_));
 sky130_fd_sc_hd__inv_2 _084_ (.A(_005_),
    .Y(_037_));
 sky130_fd_sc_hd__nor2_2 _085_ (.A(net5),
    .B(net6),
    .Y(_038_));
 sky130_fd_sc_hd__or3_2 _086_ (.A(net7),
    .B(net5),
    .C(net6),
    .X(_039_));
 sky130_fd_sc_hd__xnor2_2 _087_ (.A(net7),
    .B(_038_),
    .Y(_040_));
 sky130_fd_sc_hd__and2_2 _088_ (.A(\div_count[1] ),
    .B(\div_count[0] ),
    .X(_041_));
 sky130_fd_sc_hd__nand2b_2 _089_ (.A_N(net5),
    .B(\div_count[0] ),
    .Y(_042_));
 sky130_fd_sc_hd__a31oi_2 _090_ (.A1(net6),
    .A2(_033_),
    .A3(_042_),
    .B1(_038_),
    .Y(_043_));
 sky130_fd_sc_hd__o22a_2 _091_ (.A1(\div_count[2] ),
    .A2(_040_),
    .B1(_041_),
    .B2(_043_),
    .X(_044_));
 sky130_fd_sc_hd__or4_2 _092_ (.A(net7),
    .B(net8),
    .C(net5),
    .D(net6),
    .X(_045_));
 sky130_fd_sc_hd__a21boi_2 _093_ (.A1(net8),
    .A2(_039_),
    .B1_N(_045_),
    .Y(_046_));
 sky130_fd_sc_hd__a22o_2 _094_ (.A1(\div_count[2] ),
    .A2(_040_),
    .B1(_046_),
    .B2(\div_count[3] ),
    .X(_047_));
 sky130_fd_sc_hd__xor2_2 _095_ (.A(net9),
    .B(_045_),
    .X(_048_));
 sky130_fd_sc_hd__o22a_2 _096_ (.A1(\div_count[3] ),
    .A2(_046_),
    .B1(_048_),
    .B2(\div_count[4] ),
    .X(_049_));
 sky130_fd_sc_hd__o21ai_2 _097_ (.A1(_044_),
    .A2(_047_),
    .B1(_049_),
    .Y(_050_));
 sky130_fd_sc_hd__or3_2 _098_ (.A(net10),
    .B(net9),
    .C(_045_),
    .X(_051_));
 sky130_fd_sc_hd__o21ai_2 _099_ (.A1(net9),
    .A2(_045_),
    .B1(net10),
    .Y(_052_));
 sky130_fd_sc_hd__a32o_2 _100_ (.A1(\div_count[5] ),
    .A2(_051_),
    .A3(_052_),
    .B1(\div_count[4] ),
    .B2(_048_),
    .X(_053_));
 sky130_fd_sc_hd__inv_2 _101_ (.A(_053_),
    .Y(_054_));
 sky130_fd_sc_hd__or4_2 _102_ (.A(net10),
    .B(net9),
    .C(net11),
    .D(_045_),
    .X(_055_));
 sky130_fd_sc_hd__xor2_2 _103_ (.A(net12),
    .B(_055_),
    .X(_056_));
 sky130_fd_sc_hd__nand2_2 _104_ (.A(\div_count[7] ),
    .B(_056_),
    .Y(_057_));
 sky130_fd_sc_hd__xnor2_2 _105_ (.A(\div_count[7] ),
    .B(_056_),
    .Y(_058_));
 sky130_fd_sc_hd__o31ai_2 _106_ (.A1(net10),
    .A2(net9),
    .A3(_045_),
    .B1(net11),
    .Y(_059_));
 sky130_fd_sc_hd__a21o_2 _107_ (.A1(_055_),
    .A2(_059_),
    .B1(\div_count[6] ),
    .X(_060_));
 sky130_fd_sc_hd__nand3_2 _108_ (.A(\div_count[6] ),
    .B(_055_),
    .C(_059_),
    .Y(_061_));
 sky130_fd_sc_hd__a21o_2 _109_ (.A1(_051_),
    .A2(_052_),
    .B1(\div_count[5] ),
    .X(_062_));
 sky130_fd_sc_hd__nand3_2 _110_ (.A(_060_),
    .B(_061_),
    .C(_062_),
    .Y(_063_));
 sky130_fd_sc_hd__a211o_2 _111_ (.A1(_050_),
    .A2(_054_),
    .B1(_058_),
    .C1(_063_),
    .X(_064_));
 sky130_fd_sc_hd__o221a_2 _112_ (.A1(net12),
    .A2(_055_),
    .B1(_058_),
    .B2(_061_),
    .C1(_057_),
    .X(_065_));
 sky130_fd_sc_hd__a21oi_2 _113_ (.A1(_064_),
    .A2(_065_),
    .B1(_034_),
    .Y(_066_));
 sky130_fd_sc_hd__and2_2 _114_ (.A(net18),
    .B(net17),
    .X(_067_));
 sky130_fd_sc_hd__nor2_2 _115_ (.A(net18),
    .B(net17),
    .Y(_068_));
 sky130_fd_sc_hd__mux2_1 _116_ (.A0(_068_),
    .A1(_067_),
    .S(net1),
    .X(_069_));
 sky130_fd_sc_hd__a21o_2 _117_ (.A1(_066_),
    .A2(_069_),
    .B1(net19),
    .X(_070_));
 sky130_fd_sc_hd__o211ai_2 _118_ (.A1(net19),
    .A2(_035_),
    .B1(_066_),
    .C1(_069_),
    .Y(_071_));
 sky130_fd_sc_hd__and3_2 _119_ (.A(net3),
    .B(_070_),
    .C(_071_),
    .X(_010_));
 sky130_fd_sc_hd__nor2_2 _120_ (.A(_067_),
    .B(_068_),
    .Y(_072_));
 sky130_fd_sc_hd__xnor2_2 _121_ (.A(net1),
    .B(_072_),
    .Y(_073_));
 sky130_fd_sc_hd__a211o_2 _122_ (.A1(_064_),
    .A2(_065_),
    .B1(_073_),
    .C1(_034_),
    .X(_074_));
 sky130_fd_sc_hd__o211a_2 _123_ (.A1(net18),
    .A2(_066_),
    .B1(_074_),
    .C1(net3),
    .X(_009_));
 sky130_fd_sc_hd__xor2_2 _124_ (.A(net17),
    .B(_066_),
    .X(_075_));
 sky130_fd_sc_hd__and2_2 _125_ (.A(net3),
    .B(_075_),
    .X(_008_));
 sky130_fd_sc_hd__a21oi_2 _126_ (.A1(net3),
    .A2(_075_),
    .B1(_009_),
    .Y(_076_));
 sky130_fd_sc_hd__mux2_1 _127_ (.A0(_009_),
    .A1(_076_),
    .S(_010_),
    .X(_000_));
 sky130_fd_sc_hd__mux2_1 _128_ (.A0(_076_),
    .A1(_009_),
    .S(_010_),
    .X(_001_));
 sky130_fd_sc_hd__nand2_2 _129_ (.A(net19),
    .B(_035_),
    .Y(_077_));
 sky130_fd_sc_hd__mux2_1 _130_ (.A0(net18),
    .A1(_036_),
    .S(net2),
    .X(_078_));
 sky130_fd_sc_hd__o21ai_2 _131_ (.A1(_034_),
    .A2(_078_),
    .B1(_077_),
    .Y(net13));
 sky130_fd_sc_hd__o211a_2 _132_ (.A1(net2),
    .A2(_072_),
    .B1(_077_),
    .C1(net4),
    .X(_079_));
 sky130_fd_sc_hd__o21a_2 _133_ (.A1(_035_),
    .A2(_003_),
    .B1(_079_),
    .X(net14));
 sky130_fd_sc_hd__mux2_1 _134_ (.A0(net18),
    .A1(_004_),
    .S(net2),
    .X(_019_));
 sky130_fd_sc_hd__and3_2 _135_ (.A(net4),
    .B(_077_),
    .C(_019_),
    .X(net15));
 sky130_fd_sc_hd__mux2_1 _136_ (.A0(_037_),
    .A1(_072_),
    .S(_035_),
    .X(_020_));
 sky130_fd_sc_hd__o21ai_2 _137_ (.A1(_034_),
    .A2(_020_),
    .B1(_077_),
    .Y(net16));
 sky130_fd_sc_hd__a21oi_2 _138_ (.A1(_009_),
    .A2(_008_),
    .B1(_010_),
    .Y(_006_));
 sky130_fd_sc_hd__a21boi_2 _139_ (.A1(_009_),
    .A2(_008_),
    .B1_N(_010_),
    .Y(_007_));
 sky130_fd_sc_hd__and4_2 _140_ (.A(net4),
    .B(net3),
    .C(_064_),
    .D(_065_),
    .X(_021_));
 sky130_fd_sc_hd__and2b_2 _141_ (.A_N(\div_count[0] ),
    .B(_021_),
    .X(_011_));
 sky130_fd_sc_hd__o21ai_2 _142_ (.A1(\div_count[1] ),
    .A2(\div_count[0] ),
    .B1(_021_),
    .Y(_022_));
 sky130_fd_sc_hd__nor2_2 _143_ (.A(_041_),
    .B(_022_),
    .Y(_012_));
 sky130_fd_sc_hd__o21ai_2 _144_ (.A1(\div_count[2] ),
    .A2(_041_),
    .B1(_021_),
    .Y(_023_));
 sky130_fd_sc_hd__a21oi_2 _145_ (.A1(\div_count[2] ),
    .A2(_041_),
    .B1(_023_),
    .Y(_013_));
 sky130_fd_sc_hd__and3_2 _146_ (.A(\div_count[3] ),
    .B(\div_count[2] ),
    .C(_041_),
    .X(_024_));
 sky130_fd_sc_hd__a31o_2 _147_ (.A1(\div_count[2] ),
    .A2(\div_count[1] ),
    .A3(\div_count[0] ),
    .B1(\div_count[3] ),
    .X(_025_));
 sky130_fd_sc_hd__and3b_2 _148_ (.A_N(_024_),
    .B(_025_),
    .C(_021_),
    .X(_014_));
 sky130_fd_sc_hd__and2_2 _149_ (.A(\div_count[4] ),
    .B(_024_),
    .X(_026_));
 sky130_fd_sc_hd__o21ai_2 _150_ (.A1(\div_count[4] ),
    .A2(_024_),
    .B1(_021_),
    .Y(_027_));
 sky130_fd_sc_hd__nor2_2 _151_ (.A(_026_),
    .B(_027_),
    .Y(_015_));
 sky130_fd_sc_hd__and3_2 _152_ (.A(\div_count[5] ),
    .B(\div_count[4] ),
    .C(_024_),
    .X(_028_));
 sky130_fd_sc_hd__o21ai_2 _153_ (.A1(\div_count[5] ),
    .A2(_026_),
    .B1(_021_),
    .Y(_029_));
 sky130_fd_sc_hd__nor2_2 _154_ (.A(_028_),
    .B(_029_),
    .Y(_016_));
 sky130_fd_sc_hd__nand2_2 _155_ (.A(\div_count[6] ),
    .B(_028_),
    .Y(_030_));
 sky130_fd_sc_hd__or2_2 _156_ (.A(\div_count[6] ),
    .B(_028_),
    .X(_031_));
 sky130_fd_sc_hd__and3_2 _157_ (.A(_021_),
    .B(_030_),
    .C(_031_),
    .X(_017_));
 sky130_fd_sc_hd__xnor2_2 _158_ (.A(\div_count[7] ),
    .B(_030_),
    .Y(_032_));
 sky130_fd_sc_hd__and2_2 _159_ (.A(_021_),
    .B(_032_),
    .X(_018_));
 sky130_fd_sc_hd__dfxtp_2 _160_ (.CLK(clknet_1_0__leaf_clk),
    .D(_000_),
    .Q(_003_));
 sky130_fd_sc_hd__dfxtp_2 _161_ (.CLK(clknet_1_0__leaf_clk),
    .D(_001_),
    .Q(_005_));
 sky130_fd_sc_hd__dfxtp_2 _162_ (.CLK(clknet_1_0__leaf_clk),
    .D(_006_),
    .Q(_002_));
 sky130_fd_sc_hd__dfxtp_2 _163_ (.CLK(clknet_1_0__leaf_clk),
    .D(_007_),
    .Q(_004_));
 sky130_fd_sc_hd__dfxtp_2 _164_ (.CLK(clknet_1_0__leaf_clk),
    .D(_008_),
    .Q(net17));
 sky130_fd_sc_hd__dfxtp_2 _165_ (.CLK(clknet_1_1__leaf_clk),
    .D(_009_),
    .Q(net18));
 sky130_fd_sc_hd__dfxtp_2 _166_ (.CLK(clknet_1_0__leaf_clk),
    .D(_010_),
    .Q(net19));
 sky130_fd_sc_hd__dfxtp_2 _167_ (.CLK(clknet_1_0__leaf_clk),
    .D(_011_),
    .Q(\div_count[0] ));
 sky130_fd_sc_hd__dfxtp_2 _168_ (.CLK(clknet_1_0__leaf_clk),
    .D(_012_),
    .Q(\div_count[1] ));
 sky130_fd_sc_hd__dfxtp_2 _169_ (.CLK(clknet_1_0__leaf_clk),
    .D(_013_),
    .Q(\div_count[2] ));
 sky130_fd_sc_hd__dfxtp_2 _170_ (.CLK(clknet_1_0__leaf_clk),
    .D(_014_),
    .Q(\div_count[3] ));
 sky130_fd_sc_hd__dfxtp_2 _171_ (.CLK(clknet_1_1__leaf_clk),
    .D(_015_),
    .Q(\div_count[4] ));
 sky130_fd_sc_hd__dfxtp_2 _172_ (.CLK(clknet_1_1__leaf_clk),
    .D(_016_),
    .Q(\div_count[5] ));
 sky130_fd_sc_hd__dfxtp_2 _173_ (.CLK(clknet_1_1__leaf_clk),
    .D(_017_),
    .Q(\div_count[6] ));
 sky130_fd_sc_hd__dfxtp_2 _174_ (.CLK(clknet_1_1__leaf_clk),
    .D(_018_),
    .Q(\div_count[7] ));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__clkinvlp_4 clkload0 (.A(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input1 (.A(dir),
    .X(net1));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input10 (.A(speed_div[5]),
    .X(net10));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input11 (.A(speed_div[6]),
    .X(net11));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input12 (.A(speed_div[7]),
    .X(net12));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input2 (.A(half_step),
    .X(net2));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input3 (.A(rst_n),
    .X(net3));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input4 (.A(run),
    .X(net4));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input5 (.A(speed_div[0]),
    .X(net5));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input6 (.A(speed_div[1]),
    .X(net6));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input7 (.A(speed_div[2]),
    .X(net7));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input8 (.A(speed_div[3]),
    .X(net8));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input9 (.A(speed_div[4]),
    .X(net9));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output13 (.A(net13),
    .X(coil[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output14 (.A(net14),
    .X(coil[1]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output15 (.A(net15),
    .X(coil[2]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output16 (.A(net16),
    .X(coil[3]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output17 (.A(net17),
    .X(state_dbg[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output18 (.A(net18),
    .X(state_dbg[1]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output19 (.A(net19),
    .X(state_dbg[2]));
endmodule
