module hockey(

    input clk,
    input rst,
    
    input BTNA,
    input BTNB,
    
    input [1:0] DIRA,
    input [1:0] DIRB,
    
    input [2:0] YA,
    input [2:0] YB,
   
    output reg LEDA,
    output reg LEDB,
    output reg [4:0] LEDX,
    
    output reg [6:0] SSD7,
    output reg [6:0] SSD6,
    output reg [6:0] SSD5,
    output reg [6:0] SSD4, 
    output reg [6:0] SSD3,
    output reg [6:0] SSD2,
    output reg [6:0] SSD1,
    output reg [6:0] SSD0   
    
    );
    
    // you may use additional always blocks or drive SSDs and LEDs in one always block
parameter S_WAIT_FIRST_INPUT = 4'b0001;
parameter S_DISPLAY_SCORE = 4'b0010;
parameter S_WAIT_INPUT_A = 4'b0011;
parameter S_MOVE_PUCK_A = 4'b0100;
parameter S_WAIT_INPUT_B = 4'b0101;
parameter S_MOVE_PUCK_B = 4'b0110;
parameter S_SCORE_A = 4'b0111;
parameter S_SCORE_B = 4'b1000;
parameter S_GAME_OVER = 4'b1001;
parameter S_RESP_A = 4'b1010;
parameter S_RESP_B= 4'b1011;
//parameter LEDSTATE;
//parameter SSDSTATE;


parameter zero=7'b0000001;
parameter one=7'b1111001;
parameter two=7'b0010010;
parameter three=7'b0000110;
parameter four=7'b1001100;
reg[6:0] SA;
reg[6:0] SB;

reg[2:0] X_COORD,Y_COORD;
//reg otherstate;
reg [3:0] state;  // Current state
reg [3:0] next_state;      // Next state
reg [1:0] score_A, score_B; // Scores for players A and B
reg [1:0]turn;             //determine if A moves first or if B moves first
reg [1:0] direction;       //store direction from input
reg [2:0]DY;               //direction for inner Y
reg[10:0] delay_counter; //counter for tracking the delay duration
reg[1:0] switch;
// State machine transition and output logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_WAIT_FIRST_INPUT;
        next_state<=S_WAIT_FIRST_INPUT;
        score_A <= 0;
        score_B <= 0;
        X_COORD <= 0;
        Y_COORD <= 0;
        turn <= 0;
        direction <= 0;
        DY<=0;
        delay_counter<=0;
        //switch<=zero;
    end else begin
        case (state)
            
            S_WAIT_FIRST_INPUT: begin
                // Wait for the first input from player A or B
                // Move to S_DISPLAY_SCORE once input is received
                if(BTNA) begin
                    turn<=2'b10;
                    next_state <= S_DISPLAY_SCORE;
                    
                end
                else begin
                    if(BTNB)begin
                        turn<=2'b01;

                        next_state <= S_DISPLAY_SCORE;
                    end
                    /*else begin
                        next_state <= S_WAIT_FIRST_INPUT;
                    end*/
                end
                
            end
            S_DISPLAY_SCORE: begin
                // Display the initial score and move to S_WAIT_INPUT_A after 1 second
                if(delay_counter<100)begin
                    delay_counter<=delay_counter+1'b1;
                    //$display("Player A: ",score_A," Player B: ",score_B
                end
                else begin
                    delay_counter<=0;
                    if(score_A==2'd3)begin
                         next_state<=S_GAME_OVER;
                     end
                    else begin 
                        if(score_B==2'd3)begin
                            next_state<=S_GAME_OVER;
                        end
                        else begin
                            if(turn==2'b01) begin
                        
                                next_state <= S_WAIT_INPUT_B;
                            end
                            else begin
                              
                                next_state <= S_WAIT_INPUT_A;
                            end
                        end
                     end
                    
                end
                
            end
            S_WAIT_INPUT_A: begin
                // Logic to wait for input from player A
                // Update DIR_A, Y_in_A and then move to S_MOVE_PUCK_A
                if(BTNA && YA<5) begin
                    
                    direction <= DIRA;
                    Y_COORD <= YA;
                    X_COORD <= 3'b000;
                    next_state <= S_MOVE_PUCK_A;
                    
                end 
                /*else begin
                    next_state <=S_WAIT_INPUT_A;
                end */  
            end
            S_MOVE_PUCK_A: begin

                if(delay_counter<100) begin
                    delay_counter<=delay_counter+1;
                end
                else begin
                    delay_counter<=0;
                    
                    if(direction==2'b00) begin
                        if(X_COORD<3)begin
                            X_COORD<=X_COORD+1'd1;
                        end
                        else begin
                            next_state<= S_RESP_B;
                            X_COORD<=X_COORD+1'd1;
                        end
                    end
                    else if(direction==2'b01) begin
                        if (X_COORD<3)begin
                                X_COORD<=X_COORD+1'd1;
                            
                            if(DY==3'b000) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD-1'd1;
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                    //$display("im incrementing");
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD+1'd1; 
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;
                                    //$display("im decrementing");  
                                end
                            end
                        end
                        else begin
                            
                            X_COORD<=X_COORD+1'd1;
                            if(DY==3'b000) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD-1'd1;
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                    //$display("im incrementing");
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD+1'd1; 
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;
                                    //$display("im decrementing");  
                                end
                            end
                            next_state<= S_RESP_B;
                            
                        end
                    end
                    else if(direction==2'b10)begin//move down diagonally
                        if (X_COORD<3)begin
                            X_COORD<=X_COORD+1'd1;
                            next_state<= S_MOVE_PUCK_A;
                            if(DY==3'b001) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD-1'd1; 
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                        end
                        else begin
                            next_state<= S_RESP_B;
                            X_COORD<=X_COORD+1'd1;
                            if(DY==3'b001) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD-1'd1; 
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                            
                        end
                        end
                    end
                end//this is it
                  
            S_WAIT_INPUT_B: begin
                if(BTNB && YB<5) begin
                    direction <= DIRB;
                    Y_COORD <= YB;
                    X_COORD <= 3'b100;
                    next_state <= S_MOVE_PUCK_B;
                end 
               
            end
            S_MOVE_PUCK_B: begin
                if(delay_counter<100) begin
                    delay_counter<=delay_counter+1; 
                end
                else begin
                    delay_counter<=0;
                    //LEDX[4]<=0;
                    if(direction==2'b00) begin //move straight
                        //$display("moving straight");
                        if (X_COORD==3'b001)begin
                            next_state= S_RESP_A;
                            X_COORD<=X_COORD-1'd1;
                         
                        end
                        else begin
                            X_COORD<=X_COORD-1'd1;
                        end
                    end
    
                    else if (direction==2'b01) begin//move up diagonally
                        //$display("moving up");
                        if (X_COORD==3'b001)begin
                            next_state<= S_RESP_A;
                            X_COORD<=X_COORD-1'd1;
                            if(DY==3'b000) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD-1'd1;
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                        end
                        else begin
                            X_COORD<=X_COORD-1'd1;
                            if(DY==3'b000) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD-1'd1;
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                        end
                        
                    end
    
                    else if(direction==2'b10) begin//move down diagonally
                        //$display("moving down");
                        if (X_COORD==3'b001)begin
                            next_state<= S_RESP_A;
                            X_COORD<=X_COORD-1'd1;
                            if(DY==3'b001) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD-1'd1; 
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                        end
                        else begin
                            X_COORD<=X_COORD-1'd1;
                             if(DY==3'b001) begin 
                                if (Y_COORD==3'b100)begin
                                    DY<=3'b000;
                                    Y_COORD<=Y_COORD-1'd1; 
                                end
                                else begin
                                    Y_COORD<=Y_COORD+1'd1;
                                end
                            
                            end
                            else begin
                                if (Y_COORD==3'b000)begin
                                    DY<=3'b001;
                                    Y_COORD<=Y_COORD+1'd1;
                                    end
                                else begin
                                    Y_COORD<=Y_COORD-1'd1;  
                                end
                            end
                        end
                        
                    end 
                end
            end
            S_RESP_A: begin
                //X_COORD<=0;
                
                if(delay_counter<100) begin
                    delay_counter<=delay_counter+1'b1;
                    //LEDA<=1;
                    
                    if(BTNA && Y_COORD==YA) begin
                        //Y_COORD<=YA;
                        //direction<=DIRA;
                        if(YA==0 && DIRA==2'b10)begin
                            direction<=2'b01;
                            Y_COORD<=1;
                        end
                        else if(YA==4 && DIRA==2'b01) begin
                            direction<=2'b10;
                            Y_COORD<=3;
                        end
                        else begin
                            direction<=DIRA;
                            //Y_COORD<=YA;
                            if(DIRA==2'b01)begin
                                Y_COORD<=YA+1;
                            end
                            else if(DIRA==2'b10) begin
                                Y_COORD<=YA-1;
                            end
                            else begin
                                Y_COORD<=YA;
                            end

                        end
                        DY<=0;
                        X_COORD <= 3'b001;
                        delay_counter<=0;
                        next_state<=S_MOVE_PUCK_A;
                    end
                    
                end
                
                else begin
                    //LEDA<=0;
                    delay_counter<=0;
                    score_B<=score_B+1;
                    //next_state<=S_SCORE_B;
                    turn<=2'b10;
                    next_state<=S_DISPLAY_SCORE;
                end

            end
            S_RESP_B: begin
                //timer for one second  
                //X_COORD<=4;             
                if(delay_counter<100) begin
                    delay_counter<=delay_counter+1'b1;
                    //LEDB<=1;
                    if(BTNB && Y_COORD==YB) begin
                        //Y_COORD<=YB;
                        //direction<=DIRB;
                        if(YB==0&&DIRB==2'b10)begin
                            direction<=2'b01;
                            Y_COORD<=YB+1;
                        end
                        else if(YB==4 && DIRB==2'b01) begin
                            direction<=2'b10;
                            Y_COORD<=YB-1;
                        end
                        else begin
                            direction<=DIRB;
                            if(DIRB==2'b01)begin
                                Y_COORD<=YB+1;
                            end
                            else if(DIRB==2'b10) begin
                                Y_COORD<=YB-1;
                            end
                            else begin
                                Y_COORD<=YB;
                            end
                        end
                        DY<=0;
                        X_COORD <= 3'b011;
                        delay_counter<=0;
                        next_state<=S_MOVE_PUCK_B;
                    end
                    
                end
                
                else begin
                    //LEDB<=0;
                    delay_counter<=0;
                    score_A<=score_A+1;
                    turn<=2'b01;
                    next_state<=S_DISPLAY_SCORE;
                    //next_state<=S_SCORE_A;
                end

            end
            S_SCORE_A: begin
                // Logic for scoring a goal for player A
                // Increment score_A, check for win condition, update displays
                turn<=2'b01;
                next_state<=S_DISPLAY_SCORE;
                /*if(score_A==2'd3)begin
                    next_state<=S_GAME_OVER;
                end
                else begin 
                    next_state<=S_DISPLAY_SCORE;
                end*/
            end
            S_SCORE_B: begin
                // Logic for scoring a goal for player B
                // Increment score_B, check for win condition, update displays
                turn<=2'b10;
                next_state<=S_DISPLAY_SCORE;
                /*if(score_B==3)begin
                    next_state<=S_GAME_OVER;
                end
                else begin
                    next_state<=S_DISPLAY_SCORE;
                end*/
            end
            S_GAME_OVER: begin
                // Handle game over logic, display final score and winne
                if(delay_counter<100)begin
                    delay_counter<=delay_counter+1'b1;
                    next_state<=S_GAME_OVER;
                    //$display("Player A: ",score_A," Player B: ",score_B);   
                end
                else begin
                    delay_counter<=0;                   
                     next_state<=S_GAME_OVER;
                end
               
                

            end

            default: begin
                // Default case to handle any undefined states
                next_state <= S_WAIT_FIRST_INPUT;
            end
        endcase

        // Update state
        state <= next_state;
    end
end

    
    // for SSDs
    always @ (*)begin
        SSD3=7'b1111111;
        SSD5=7'b1111111;
        SSD6=7'b1111111;
        SSD7=7'b1111111;
        SA=zero;
        SB=zero;
        if(state==S_WAIT_FIRST_INPUT)begin
            SA=zero;
            SB=zero;
            
            SSD0=7'b1100000;
            SSD1=7'b1111110;
            SSD2=7'b0001000;
            SSD4=7'b1111111;
        end
        
        else begin
            if(state==S_DISPLAY_SCORE)begin
                SSD4=7'b1111111;
                if(score_A==0)begin
                        SA=zero;
                    end
                    else begin
                        if(score_A==1) begin
                            SA=one;
                        end
                        else if(score_A==2) begin
                            SA=two;
                        end
                        else begin
                        SA=three;
                        end
                    end
                    
                    if(score_B==0)begin
                        SB=zero;
                    end
                    else begin
                        if(score_B==1) begin
                            SB=one;
                        end
                        else if(score_B==2) begin
                            SB=two;
                        end
                        else begin
                        SB=three;
                        end
                    end
                    SSD0=SB;
                    SSD1=7'b1111110;
                    SSD2=SA;
                    
                    
            end
            
            else begin
                if(state==S_WAIT_INPUT_A)begin
                    //SSD4=zero;
                    SSD0=7'b1111111;
                    SSD1=7'b1111111;
                    SSD2=7'b1111111;
                    SSD4=7'b1111111;
                    if(YA==0) begin
                                SSD4=zero;
                            end 
                            else begin
                                if(YA==1) begin
                                    SSD4=one;
                                end 
                                
                                else begin
                                    if(YA==2) begin
                                        SSD4=two;
                                    end 
                                    
                                    else begin
                                        if(YA==3) begin
                                            SSD4=three;
                                        end 
                                        else begin
                                            SSD4=four;
                                        end
                                    end
                                end
                            end
                end
                
                else begin
                    if(state==S_WAIT_INPUT_B)begin
                        //SSD4=zero;
                        SSD0=7'b1111111;
                        SSD1=7'b1111111;
                        SSD2=7'b1111111;
                        //SSD4=7'b1111111;
                        if(YB==0) begin
                                SSD4=zero;
                            end 
                            else begin
                                if(YB==1) begin
                                    SSD4=one;
                                end 
                                
                                else begin
                                    if(YB==2) begin
                                        SSD4=two;
                                    end 
                                    
                                    else begin
                                        if(YB==3) begin
                                            SSD4=three;
                                        end 
                                        else begin
                                            SSD4=four;
                                        end
                                    end
                                end
                            end
                    end
                    
                    else begin
                        if(state==S_MOVE_PUCK_A)begin
                            SSD1=7'b1111111;
                                    SSD2=7'b1111111;
                                    SSD0=7'b1111111;
                            if(Y_COORD==0) begin
                                SSD4=zero;
                            end 
                            else begin
                                if(Y_COORD==1) begin
                                    SSD4=one;
                                end 
                                
                                else begin
                                    if(Y_COORD==2) begin
                                        SSD4=two;
                                    end 
                                    
                                    else begin
                                        if(Y_COORD==3) begin
                                            SSD4=three;
                                        end 
                                        else begin
                                            SSD4=four;
                                        end
                                    end
                                end
                            end
                        
                        end
                        
                        else begin
                            if(state==S_MOVE_PUCK_B)begin
                                SSD1=7'b1111111;
                                    SSD2=7'b1111111;
                                    SSD0=7'b1111111;
                                if(Y_COORD==0) begin
                                    SSD4=zero;
                                end 
                                else begin
                                    if(Y_COORD==1) begin
                                        SSD4=one;
                                    end 
                                    
                                    else begin
                                        if(Y_COORD==2) begin
                                            SSD4=two;
                                        end 
                                        
                                        else begin
                                            if(Y_COORD==3) begin
                                                SSD4=three;
                                            end 
                                            else begin
                                                SSD4=four;
                                            end
                                        end
                                    end
                                end                            
                            end
                            else begin
                                if(state==S_RESP_A)begin
                                    //SSD4=7'b1111111;
                                    SSD1=7'b1111111;
                                    SSD2=7'b1111111;
                                    SSD0=7'b1111111;
                                    if(Y_COORD==0) begin
                                SSD4=zero;
                            end 
                            else begin
                                if(Y_COORD==1) begin
                                    SSD4=one;
                                end 
                                
                                else begin
                                    if(Y_COORD==2) begin
                                        SSD4=two;
                                    end 
                                    
                                    else begin
                                        if(Y_COORD==3) begin
                                            SSD4=three;
                                        end 
                                        else begin
                                            SSD4=four;
                                        end
                                    end
                                end
                            end
                                end
                                else begin
                                    if(state==S_RESP_B)begin
                                        //SSD4=7'b1111111;
                                        SSD1=7'b1111111;
                                        SSD2=7'b1111111;
                                        SSD0=7'b1111111;
                                        if(Y_COORD==0) begin
                                SSD4=zero;
                            end 
                            else begin
                                if(Y_COORD==1) begin
                                    SSD4=one;
                                end 
                                
                                else begin
                                    if(Y_COORD==2) begin
                                        SSD4=two;
                                    end 
                                    
                                    else begin
                                        if(Y_COORD==3) begin
                                            SSD4=three;
                                        end 
                                        else begin
                                            SSD4=four;
                                        end
                                    end
                                end
                            end
                                    end
                                    else begin
                                        if(state==S_GAME_OVER)begin
                                            if(score_A==3)begin
                                                //$display("Player A is the winner");
                                                SSD4=7'b0001000;
                                                if(score_B==0)begin
                                                    SB=zero;
                                                end
                                                else begin
                                                    if(score_B==1) begin
                                                        SB=one;
                                                    end
                                                    else begin
                                                        SB=two;
                                                    end
                                                end
                                                SSD0=SB;
                                                SSD1=7'b1111110;
                                                SSD2=three;
                                            
                                            end
                                            else begin
                                                //$display("Player B is the winner");
                                                SSD4=7'b1100000;
                                                if(score_A==0)begin
                                                    SA=zero;
                                                end
                                                else begin
                                                    if(score_A==1) begin
                                                        SA=one;
                                                    end
                                                    else begin
                                                        SA=two;
                                                    end
                                                end
                                                SSD0=three;
                                                SSD1=7'b1111110;
                                                SSD2=SA;
                                            end
                                            end
                                            else begin
                                            SSD0=7'b1111111;
                                                SSD1=7'b1111111;
                                                SSD2=7'b1111111;
                                                SSD4=7'b1111111;
                                            end
                                    end
                                  
                               
                                end
                                
                            end
                        
                        end
                        
                    end
                end
            end
        end
        
        
    
    end
    
    //for LEDs
    always @ (*)
    begin
    
        if(state==S_WAIT_FIRST_INPUT)begin
            LEDA=1;
            LEDB=1;
            LEDX[4]=0;
            LEDX[3]=0;
            LEDX[2]=0;
            LEDX[1]=0;
            LEDX[0]=0;
            //switch=0;
        end
        
        else begin
            if(state==S_DISPLAY_SCORE)begin
                 LEDX[4]=1;
                LEDX[3]=1;
                LEDX[2]=1;
                LEDX[1]=1;
                LEDX[0]=1;
                 LEDA=0;
                 LEDB=0;
            end
            
            else begin
                if(state==S_WAIT_INPUT_A)begin
                    LEDA=1;
                    LEDB=0;
                                LEDX[4]=0;
            LEDX[3]=0;
            LEDX[2]=0;
            LEDX[1]=0;
            LEDX[0]=0;
                end
                
                else begin
                    if(state==S_WAIT_INPUT_B)begin
                        LEDA=0;
                        LEDB=1;
                                    LEDX[4]=0;
            LEDX[3]=0;
            LEDX[2]=0;
            LEDX[1]=0;
            LEDX[0]=0;
                    end
                    else begin
                        if(state==S_MOVE_PUCK_A)begin
                            LEDA=0;
                            //LEDB=0;
                            if(X_COORD==0) begin
                                LEDX[4]=1;
                                LEDX[3]=0;
                                LEDX[2]=0;
                                LEDX[1]=0;
                                LEDX[0]=0;
                                LEDB=0;
                            end 
                            else begin
                                if(X_COORD==1) begin
                                    LEDX[4]=0;
                                    LEDX[3]=1;
                                    LEDX[2]=0;
                                    LEDX[1]=0;
                                    LEDX[0]=0;
                                    LEDB=0;
                                end 
                                
                                else begin
                                    if(X_COORD==2) begin
                                        LEDX[4]=0;
                                        LEDX[3]=0;
                                        LEDX[2]=1;
                                        LEDX[1]=0;
                                        LEDX[0]=0;
                                        LEDB=0;
                                    end 
                                    
                                    else begin
                                        if(X_COORD==3) begin
                                            LEDX[4]=0;
                                            LEDX[3]=0;
                                            LEDX[2]=0;
                                            LEDX[1]=1;
                                            LEDX[0]=0;
                                            LEDB=0;
                                        end 
                                        else begin
                                            LEDX[4]=0;
                                            LEDX[3]=0;
                                            LEDX[2]=0;
                                            LEDX[1]=0;
                                            LEDX[0]=1;
                                            LEDB=1;
                                        end
                                    end
                                end
                            end
                        end
                        else begin
                            if(state==S_MOVE_PUCK_B)begin
                                //LEDA=0;
                                LEDB=0;
                                if(X_COORD==0) begin
                                    LEDX[4]=1;
                                    LEDX[3]=0;
                                    LEDX[2]=0;
                                    LEDX[1]=0;
                                    LEDX[0]=0;
                                    LEDA=1;
                                end 
                                else begin
                                    if(X_COORD==1) begin
                                        LEDX[4]=0;
                                        LEDX[3]=1;
                                        LEDX[2]=0;
                                        LEDX[1]=0;
                                        LEDX[0]=0;
                                        LEDA=0;
                                    end 
                                    
                                    else begin
                                        if(X_COORD==2) begin
                                            LEDX[4]=0;
                                            LEDX[3]=0;
                                            LEDX[2]=1;
                                            LEDX[1]=0;
                                            LEDX[0]=0;
                                            LEDA=0;
                                        end 
                                        
                                        else begin
                                            if(X_COORD==3) begin
                                                LEDX[4]=0;
                                                LEDX[3]=0;
                                                LEDX[2]=0;
                                                LEDX[1]=1;
                                                LEDX[0]=0;
                                                LEDA=0;
                                            end 
                                            else begin
                                                LEDX[4]=0;
                                                LEDX[3]=0;
                                                LEDX[2]=0;
                                                LEDX[1]=0;
                                                LEDX[0]=1;
                                                LEDA=0;
                                            end
                                        end
                                    end
                                end
                            end
                            else begin
                                if(state==S_RESP_A)begin
                                    LEDX[4]=1;
                                    LEDX[3]=0;
                                    LEDX[2]=0;
                                    LEDX[1]=0;
                                    LEDX[0]=0;
                                    LEDA=1;
                                    LEDB=0;
                                   
                                end
                                else begin
                                    if(state==S_RESP_B)begin
                                        LEDX[4]=0;
                                        LEDX[3]=0;
                                        LEDX[2]=0;
                                        LEDX[1]=0;
                                        LEDX[0]=1;
                                        
                                        LEDA=0;
                                        LEDB=1;
                                    end
                                    
                                    else begin
                                        if(state==S_SCORE_A)begin
                                            LEDA=0;
                                            LEDB=0;
                                            LEDX[4]=0;
                                        LEDX[3]=0;
                                        LEDX[2]=0;
                                        LEDX[1]=0;
                                        LEDX[0]=1;
                                        end
                                        
                                        else begin
                                            if(state==S_SCORE_B)begin
                                                LEDA=0;
                                                LEDB=0;
                                                LEDX[4]=0;
                                        LEDX[3]=0;
                                        LEDX[2]=0;
                                        LEDX[1]=0;
                                        LEDX[0]=1;
                                            end
                                            
                                            else begin
                                                if(state==S_GAME_OVER) begin
                                                    LEDA=0;
                                                    LEDB=0;
                                                    if(delay_counter<50) begin
                                                        LEDX[4]=1;
                                                        LEDX[3]=0;
                                                        LEDX[2]=1;
                                                        LEDX[1]=0;
                                                        LEDX[0]=1;
                                                        //switch=1;
                                                    end 
                                                    else begin
                                                        LEDX[4]=0;
                                                        LEDX[3]=1;
                                                        LEDX[2]=0;
                                                        LEDX[1]=1;
                                                        LEDX[0]=0;
                                                        //switch=0;
                                                    end
                                                end
                                                else begin
                                                    LEDA=0;
                                                    LEDB=0;
                                                    LEDX[4]=0;
                                                    LEDX[3]=0;
                                                    LEDX[2]=0;
                                                    LEDX[1]=0;
                                                    LEDX[0]=0;
                                                end
                                            end
                                        end
                                    end
                                end
                                
                            end
                        end
                    end
                end
            end
        end
    end
        
      
    
    
    
endmodule
