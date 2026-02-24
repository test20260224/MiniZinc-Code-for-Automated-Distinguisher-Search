% Automated impossible differential search for Gen-RC6

% Basic runtime parameters
int: RD = 9;        % Number of rounds
int: BRENCH = 4;    % Number of brenchs
int: NUM = 2;       % Number of functions per round

% Next round number (permutation of previous)
array[0..BRENCH-1] of var 0..BRENCH-1: flag;
constraint
(
    flag[0..BRENCH-1] = array1d(0..BRENCH-1, [3, 0, 1, 2])
);

% Forward Constrains
array[0..RD, 0..BRENCH-1] of var 0..1: X;                       % Deterministic (fixed) component of the differencial pattern
array[0..RD, 0..BRENCH-1, 0..NUM-1] of var 0..(2^(RD+1)): Y;    % Nonzero-but-undetermined component of the differencial pattern
array[0..RD, 0..BRENCH-1, 0..NUM-1] of var 0..(2^(RD+1)): Z;    % Undetermined component of the differencial pattern
array[0..(RD-1), 0..NUM-1] of var 0..(2^(RD+1)): YF_output;     % Nonzero-but-undetermined component of the output of S-box
array[0..(RD-1), 0..NUM-1] of var 0..(2^(RD+1)): ZF_output;     % Undetermined component of the output of S-box
constraint
(
   sum([X[0, i] | i in 0..BRENCH-1]) <= 4
);
constraint forall(i in 0..BRENCH-1, j in 0..(NUM-1))
(
    Y[0, i, j] == 0 /\ Z[0, i, j] == 0
);
constraint exists(i in 0..BRENCH-1)
(
    X[0,i] >= 1
);
constraint forall(round in 1..RD)
(
    forall(i in 0..BRENCH-1, j in 0..(NUM-1)) (
    (Y[round, i, j] <= 2^(round+1)) /\ 
    (Z[round, i, j] <= 2^(round+1))
    )
);
constraint forall(round in 0..(RD-1), i in 0..(NUM-1))
(
    (YF_output[round, i] == 0 \/ YF_output[round, i] == 2^(round+1))
    /\
    (ZF_output[round, i] == 0 \/ ZF_output[round, i] == 2^(round+1))
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    F(array1d(0..(2*NUM), [X[round, 2*i+1]] ++ [Y[round, 2*i+1, j] | j in 0..NUM-1] ++ [Z[round, 2*i+1, j] | j in 0..NUM-1]), YF_output[round, i], ZF_output[round, i], round)
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    XORYZ(YF_output[round, i], ZF_output[round, i], array1d(0..(2*NUM), [X[round, 2*i]] ++ [Y[round, 2*i, j] | j in 0..NUM-1] ++ [Z[round, 2*i, j] | j in 0..NUM-1]), array1d(0..(2*NUM), [X[round+1, flag[2*i]]]++[Y[round+1, flag[2*i], j] | j in 0..NUM-1]++[Z[round+1, flag[2*i], j] | j in 0..NUM-1]), i)
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    X[round+1, flag[2*i+1]] = X[round, 2*i+1] /\ 
    forall(j in 0..(NUM-1))(Y[round+1, flag[2*i+1], j] = Y[round, 2*i+1, j] /\ Z[round+1, flag[2*i+1], j] = Z[round, 2*i+1, j]) 
);

% Backward Constrains
array[0..RD, 0..BRENCH-1] of var 0..1: XB;                      % Deterministic (fixed) component of the differencial pattern
array[0..RD, 0..BRENCH-1, 0..NUM-1] of var 0..(2^(RD+1)): YB;   % Nonzero-but-undetermined component of the differencial pattern
array[0..RD, 0..BRENCH-1, 0..NUM-1] of var 0..(2^(RD+1)): ZB;   % Undetermined component of the differencial pattern
array[0..(RD-1), 0..NUM-1] of var 0..(2^(RD+1)): YBF_output;    % Nonzero-but-undetermined component of the output of S-box
array[0..(RD-1), 0..NUM-1] of var 0..(2^(RD+1)): ZBF_output;    % Undetermined component of the output of S-box
constraint
(
   sum([XB[RD, i] | i in 0..BRENCH-1]) <= 4
);
constraint forall(i in 0..BRENCH-1, j in 0..NUM-1)
(
    YB[RD, i, j] == 0 /\ ZB[RD, i, j] == 0
);
constraint exists(i in 0..BRENCH-1)
(
    XB[RD,i] >= 1
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    (YBF_output[round, i] == 0 \/ YBF_output[round, i] == 2^(round+1))
    /\
    (ZBF_output[round, i] == 0 \/ ZBF_output[round, i] == 2^(round+1))
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    XB[round+1, flag[2*i+1]] = XB[round, 2*i+1] /\ 
    forall(j in 0..(NUM-1))(YB[round+1, flag[2*i+1], j] = YB[round, 2*i+1, j] /\ ZB[round+1, flag[2*i+1], j] = ZB[round, 2*i+1, j]) 
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    F(array1d(0..(2*NUM), [XB[round, 2*i+1]] ++ [YB[round, 2*i+1, j] | j in 0..NUM-1] ++ [ZB[round, 2*i+1, j] | j in 0..NUM-1]), YBF_output[round, i], ZBF_output[round, i], round)
);
constraint forall(round in 0..(RD-1), i in 0..NUM-1)
(
    XORYZ(YBF_output[round, i], ZBF_output[round, i], array1d(0..(2*NUM), [XB[round+1, flag[2*i]]]++[YB[round+1, flag[2*i], j] | j in 0..NUM-1]++[ZB[round+1, flag[2*i], j] | j in 0..NUM-1]), array1d(0..(2*NUM), [XB[round, 2*i]] ++ [YB[round, 2*i, j] | j in 0..NUM-1] ++ [ZB[round, 2*i, j] | j in 0..NUM-1]), i)
);

% XOR branch selection
array[0..BRENCH-1] of var 0..1: select;
constraint sum(select) <= 4;

% Inconsistency-enforcement constraints
array[0..2*NUM] of var 0..(2^(RD+1)): contradict1;
array[0..2*NUM] of var 0..(2^(RD+1)): contradict2;
array[0..2*NUM] of var 0..(2^(RD+1)): contradict;
constraint exists(round in 0..RD)
(
    SELECT_XOR4( array1d(0..(2*NUM), [X[round, 0]]++[Y[round, 0, j] | j in 0..(NUM-1)]++[Z[round, 0, j] | j in 0..(NUM-1)]), 
    array1d(0..(2*NUM), [X[round, 1]]++[Y[round, 1, j] | j in 0..(NUM-1)]++[Z[round, 1, j] | j in 0..(NUM-1)]),
    array1d(0..(2*NUM), [X[round, 2]]++[Y[round, 2, j] | j in 0..(NUM-1)]++[Z[round, 2, j] | j in 0..(NUM-1)]),
    array1d(0..(2*NUM), [X[round, 3]]++[Y[round, 3, j] | j in 0..(NUM-1)]++[Z[round, 3, j] | j in 0..(NUM-1)]),
    contradict1[0..2*NUM], select[0..BRENCH-1]) /\
    
    SELECT_XOR4( array1d(0..(2*NUM), [XB[round, 0]]++[YB[round, 0, j] | j in 0..(NUM-1)]++[ZB[round, 0, j] | j in 0..(NUM-1)]), 
    array1d(0..(2*NUM), [XB[round, 1]]++[YB[round, 1, j] | j in 0..(NUM-1)]++[ZB[round, 1, j] | j in 0..(NUM-1)]),
    array1d(0..(2*NUM), [XB[round, 2]]++[YB[round, 2, j] | j in 0..(NUM-1)]++[ZB[round, 2, j] | j in 0..(NUM-1)]),
    array1d(0..(2*NUM), [XB[round, 3]]++[YB[round, 3, j] | j in 0..(NUM-1)]++[ZB[round, 3, j] | j in 0..(NUM-1)]),
    contradict2[0..2*NUM], select[0..BRENCH-1]) /\
    
    XOR(contradict1[0..2*NUM], contradict2[0..2*NUM], contradict[0..2*NUM]) /\
    
    (  (contradict[0] >= 1 /\ forall(j in 1..2*NUM)(contradict[j] = 0 )) \/ (exists(j in 0..NUM)(isPowertwo(contradict[j]) /\ forall(k in 0..2*NUM where k != j)(contradict[k] == 0)))  )
);

% F-function
predicate F(
    array[0..2*NUM] of var int: F_input, 
    var int: Y_output, var int: Z_output,  
    int: round) =
    if (forall(i in 0..2*NUM)(F_input[i] == 0)) then 
        (Y_output == 0 /\ Z_output == 0)
    elseif (F_input[0] >= 1 /\ forall(i in 1..2*NUM)(F_input[i] == 0)) then 
        (Y_output == 2^(round+1) /\ Z_output == 0)
    elseif (exists(i in 0..NUM)(isPowertwo(F_input[i]) /\ forall(j in 0..2*NUM where j != i)(F_input[j] == 0))) then 
        (Y_output == 2^(round+1) /\ Z_output == 0)
    else 
        (Y_output == 0 /\ Z_output == 2^(round+1))
    endif;

% XOR
predicate XORYZ(var int: YF_output, var int: ZF_output, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, int: i) =
    (
    	forall(j in 0..2*NUM where (j !=i+1 /\ j!=i+1+NUM) ) (c[j] == b[j]) /\
    	Numxor(YF_output, b[i+1], c[i+1]) /\
    	Numxor(ZF_output, b[i+1+NUM], c[i+1+NUM])
    );
predicate XOR(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c) =
    (
        forall(i in 0..2*NUM) (Numxor(a[i], b[i], c[i]))
    );
predicate XOR3(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: result) =
    let {
        array[0..2*NUM] of var int: temp_result_1 % intermediate result for first XOR
    } in (
        % First XOR between a and b
        XOR(a, b, temp_result_1) /\
        
        % Second XOR between the result of the first XOR and c
        XOR(temp_result_1, c, result)
    );
predicate XOR4(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: result) =
    let {
        array[0..2*NUM] of var int: temp_result_1, % intermediate result for first XOR
        array[0..2*NUM] of var int: temp_result_2  % intermediate result for second XOR
    } in (
        % First XOR between a and b
        XOR(a, b, temp_result_1) /\
        
        % Second XOR between the result of the first XOR and c
        XOR(temp_result_1, c, temp_result_2) /\
        
        % Final XOR between the result and d
        XOR(temp_result_2, d, result)
    );
predicate XOR8(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: e, array[0..2*NUM] of var int: f, array[0..2*NUM] of var int: g, array[0..2*NUM] of var int: h, array[0..2*NUM] of var int: result) =
    let {
        array[0..2*NUM] of var int: temp_result_1, % intermediate result for first XOR
        array[0..2*NUM] of var int: temp_result_2  % intermediate result for second XOR
    } in (
        % First XOR between a and b
        XOR4(a, b, c, d, temp_result_1) /\
        
        % Second XOR between the result of the first XOR and c
        XOR4(e, f, g, h, temp_result_2) /\
        
        % Final XOR between the result and d
        XOR(temp_result_2, temp_result_1, result)
    );
predicate XOR16(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: e, array[0..2*NUM] of var int: f, array[0..2*NUM] of var int: g, array[0..2*NUM] of var int: h, array[0..2*NUM] of var int: i, array[0..2*NUM] of var int: j, array[0..2*NUM] of var int: k, array[0..2*NUM] of var int: l, array[0..2*NUM] of var int: m, array[0..2*NUM] of var int: n, array[0..2*NUM] of var int: o, array[0..2*NUM] of var int: p, array[0..2*NUM] of var int: result) =
    let {
        array[0..2*NUM] of var int: temp_result_1, % intermediate result for first XOR
        array[0..2*NUM] of var int: temp_result_2  % intermediate result for second XOR
    } in (
        % First XOR between a and b
        XOR8(a, b, c, d, e, f, g, h, temp_result_1) /\
        
        % Second XOR between the result of the first XOR and c
        XOR8(i, j, k, l, m, n, o, p, temp_result_2) /\
        
        % Final XOR between the result and d
        XOR(temp_result_2, temp_result_1, result)
    );
predicate XOR32(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: e, array[0..2*NUM] of var int: f, array[0..2*NUM] of var int: g, array[0..2*NUM] of var int: h, array[0..2*NUM] of var int: i, array[0..2*NUM] of var int: j, array[0..2*NUM] of var int: k, array[0..2*NUM] of var int: l, array[0..2*NUM] of var int: m, array[0..2*NUM] of var int: n, array[0..2*NUM] of var int: o, array[0..2*NUM] of var int: p, array[0..2*NUM] of var int: a1, array[0..2*NUM] of var int: b1, array[0..2*NUM] of var int: c1, array[0..2*NUM] of var int: d1, array[0..2*NUM] of var int: e1, array[0..2*NUM] of var int: f1, array[0..2*NUM] of var int: g1, array[0..2*NUM] of var int: h1, array[0..2*NUM] of var int: i1, array[0..2*NUM] of var int: j1, array[0..2*NUM] of var int: k1, array[0..2*NUM] of var int: l1, array[0..2*NUM] of var int: m1, array[0..2*NUM] of var int: n1, array[0..2*NUM] of var int: o1, array[0..2*NUM] of var int: p1, array[0..2*NUM] of var int: result) =
    let {
        array[0..2*NUM] of var int: temp_result_1, % intermediate result for first XOR
        array[0..2*NUM] of var int: temp_result_2  % intermediate result for second XOR
    } in (
        % First XOR between a and b
        XOR16(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, temp_result_1) /\
        
        % Second XOR between the result of the first XOR and c
        XOR16(a1, b1, c1, d1, e1, f1, g1, h1, i1, j1, k1, l1, m1, n1, o1, p1, temp_result_2) /\
        
        % Final XOR between the result and d
        XOR(temp_result_2, temp_result_1, result)
    );

% Select-XOR
predicate SELECT_XOR4(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: result, array[0..BRENCH-1] of var 0..1: select) =
    let {
        array[0..2*NUM] of var int: flag0,
        array[0..2*NUM] of var int: flag1,
        array[0..2*NUM] of var int: flag2,
        array[0..2*NUM] of var int: flag3
        
    } in (
        SELECT(a, select[0], flag0) /\
        SELECT(b, select[1], flag1) /\
        SELECT(c, select[2], flag2) /\
        SELECT(d, select[3], flag3) /\
        
        % First XOR between a and b
        XOR4(flag0, flag1, flag2, flag3, result)
    );


predicate SELECT_XOR32(array[0..2*NUM] of var int: a, array[0..2*NUM] of var int: b, array[0..2*NUM] of var int: c, array[0..2*NUM] of var int: d, array[0..2*NUM] of var int: e, array[0..2*NUM] of var int: f, array[0..2*NUM] of var int: g, array[0..2*NUM] of var int: h, array[0..2*NUM] of var int: i, array[0..2*NUM] of var int: j, array[0..2*NUM] of var int: k, array[0..2*NUM] of var int: l, array[0..2*NUM] of var int: m, array[0..2*NUM] of var int: n, array[0..2*NUM] of var int: o, array[0..2*NUM] of var int: p, array[0..2*NUM] of var int: a1, array[0..2*NUM] of var int: b1, array[0..2*NUM] of var int: c1, array[0..2*NUM] of var int: d1, array[0..2*NUM] of var int: e1, array[0..2*NUM] of var int: f1, array[0..2*NUM] of var int: g1, array[0..2*NUM] of var int: h1, array[0..2*NUM] of var int: i1, array[0..2*NUM] of var int: j1, array[0..2*NUM] of var int: k1, array[0..2*NUM] of var int: l1, array[0..2*NUM] of var int: m1, array[0..2*NUM] of var int: n1, array[0..2*NUM] of var int: o1, array[0..2*NUM] of var int: p1, array[0..2*NUM] of var int: result, array[0..31] of var 0..1: select) =
    let {
        array[0..2*NUM] of var int: flag0,
        array[0..2*NUM] of var int: flag1,
        array[0..2*NUM] of var int: flag2,
        array[0..2*NUM] of var int: flag3,
        array[0..2*NUM] of var int: flag4,
        array[0..2*NUM] of var int: flag5,
        array[0..2*NUM] of var int: flag6,
        array[0..2*NUM] of var int: flag7,
        array[0..2*NUM] of var int: flag8,
        array[0..2*NUM] of var int: flag9,
        array[0..2*NUM] of var int: flag10,
        array[0..2*NUM] of var int: flag11,
        array[0..2*NUM] of var int: flag12,
        array[0..2*NUM] of var int: flag13,
        array[0..2*NUM] of var int: flag14,
        array[0..2*NUM] of var int: flag15,
        array[0..2*NUM] of var int: flag16,
        array[0..2*NUM] of var int: flag17,
        array[0..2*NUM] of var int: flag18,
        array[0..2*NUM] of var int: flag19,
        array[0..2*NUM] of var int: flag20,
        array[0..2*NUM] of var int: flag21,
        array[0..2*NUM] of var int: flag22,
        array[0..2*NUM] of var int: flag23,
        array[0..2*NUM] of var int: flag24,
        array[0..2*NUM] of var int: flag25,
        array[0..2*NUM] of var int: flag26,
        array[0..2*NUM] of var int: flag27,
        array[0..2*NUM] of var int: flag28,
        array[0..2*NUM] of var int: flag29,
        array[0..2*NUM] of var int: flag30,
        array[0..2*NUM] of var int: flag31
    } in (
        SELECT(a, select[0], flag0) /\
        SELECT(b, select[1], flag1) /\
        SELECT(c, select[2], flag2) /\
        SELECT(d, select[3], flag3) /\
        SELECT(e, select[4], flag4) /\
        SELECT(f, select[5], flag5) /\
        SELECT(g, select[6], flag6) /\
        SELECT(h, select[7], flag7) /\
        SELECT(i, select[8], flag8) /\
        SELECT(j, select[9], flag9) /\
        SELECT(k, select[10], flag10) /\
        SELECT(l, select[11], flag11) /\
        SELECT(m, select[12], flag12) /\
        SELECT(n, select[13], flag13) /\
        SELECT(o, select[14], flag14) /\
        SELECT(p, select[15], flag15) /\
        SELECT(a1, select[16], flag16) /\
        SELECT(b1, select[17], flag17) /\
        SELECT(c1, select[18], flag18) /\
        SELECT(d1, select[19], flag19) /\
        SELECT(e1, select[20], flag20) /\
        SELECT(f1, select[21], flag21) /\
        SELECT(g1, select[22], flag22) /\
        SELECT(h1, select[23], flag23) /\
        SELECT(i1, select[24], flag24) /\
        SELECT(j1, select[25], flag25) /\
        SELECT(k1, select[26], flag26) /\
        SELECT(l1, select[27], flag27) /\
        SELECT(m1, select[28], flag28) /\
        SELECT(n1, select[29], flag29) /\
        SELECT(o1, select[30], flag30) /\
        SELECT(p1, select[31], flag31) /\
        % First XOR between a and b
        XOR32(flag0, flag1, flag2, flag3, flag4, flag5, flag6, flag7, flag8, flag9, flag10, flag11, flag12, flag13, flag14, flag15, flag16, flag17, flag18, flag19, flag20, flag21, flag22, flag23, flag24, flag25, flag26, flag27, flag28, flag29, flag30, flag31, result)
    );
predicate SELECT(array[0..2*NUM] of var int: a, var int: flag, array[0..2*NUM] of var int: result) = 
    if (flag == 0) then 
        (forall(i in 0..2*NUM) (result[i] == 0))
    else
        (forall(i in 0..2*NUM) (result[i] == a[i]))
    endif;

% Bitwise XOR
predicate Numxor(var int: num1, var int: num2,var int: result) =
    let {
        % Define binary bit width
        int: BIT_LENGTH = RD+1,

        % Define binary arrays (represented as booleans for each bit)
        array[1..BIT_LENGTH] of var bool: bin1,
        array[1..BIT_LENGTH] of var bool: bin2,
        array[1..BIT_LENGTH] of var bool: xor_bin
    } in (
        % Convert num1 and num2 to boolean binary representation
        num1 = sum([bool2int(bin1[i]) * 2^(i - 1) | i in 1..BIT_LENGTH]) /\
        num2 = sum([bool2int(bin2[i]) * 2^(i - 1) | i in 1..BIT_LENGTH]) /\

        % Perform XOR bitwise operation
        forall(i in 1..BIT_LENGTH)(
            xor_bin[i] = bin1[i] xor bin2[i]
        ) /\

        % Convert boolean binary arrays back to integers
        result = sum([bool2int(xor_bin[i]) * 2^(i - 1) | i in 1..BIT_LENGTH])
    );

% Check if it is a power of 2
predicate isPowertwo(var int: x) = 
    exists(i in 1..(RD+1)) (x = 2^i);



