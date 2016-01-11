; Script generated by the pharmML2Nmtran Converter v.0.3.0
; Source	: PharmML 0.6.1
; Target	: NMTRAN 7.3.0
; Model 	: UseCase3
; Dated 	: Wed Dec 09 19:37:44 GMT 2015

$PROBLEM "generated by MDL2PharmML v.6.0"

$INPUT  ID TIME=TIME WT AGE=DROP SEX=DROP AMT DVID DV MDV
$DATA "warfarin_conc_pca.csv" IGNORE=@
$SUBS ADVAN13 TOL=6

$MODEL 
COMP (COMP1) 	;GUT
COMP (COMP2) 	;CENTRAL
COMP (COMP3) 	;PCA



$PK 
POP_CL = THETA(1)
POP_V = THETA(2)
POP_KA = THETA(3)
POP_TLAG = THETA(4)
POP_PCA0 = THETA(5)
POP_C50 = THETA(6)
POP_TEQ = THETA(7)
RUV_PROP = THETA(8)
RUV_ADD = THETA(9)
RUV_FX = THETA(10)
POP_EMAX = THETA(11)
BETA_CL_WT = THETA(12)
BETA_V_WT = THETA(13)

ETA_CL =  ETA(1)
ETA_V =  ETA(2)
ETA_KA =  ETA(3)
ETA_TLAG =  ETA(4)
ETA_PCA0 =  ETA(5)
ETA_EMAX =  ETA(6)
ETA_C50 =  ETA(7)
ETA_TEQ =  ETA(8)

LOGTWT = LOG((WT/70))


MU_1 = LOG(POP_CL) + BETA_CL_WT * LOGTWT
CL =  EXP(MU_1 +  ETA(1)) ;

MU_2 = LOG(POP_V) + BETA_V_WT * LOGTWT
V =  EXP(MU_2 +  ETA(2)) ;

MU_3 = LOG(POP_KA)
KA =  EXP(MU_3 +  ETA(3)) ;

MU_4 = LOG(POP_TLAG)
TLAG =  EXP(MU_4 +  ETA(4)) ;

MU_5 = LOG(POP_PCA0)
PCA0 =  EXP(MU_5 +  ETA(5)) ;

MU_6 =  POP_EMAX 
EMAX =  MU_6 +  ETA(6);

MU_7 = LOG(POP_C50)
C50 =  EXP(MU_7 +  ETA(7)) ;

MU_8 = LOG(POP_TEQ)
TEQ =  EXP(MU_8 +  ETA(8)) ;

A_0(1) = 0
A_0(2) = 0
A_0(3) = PCA0

$DES 
GUT_DES = A(1)
CENTRAL_DES = A(2)
PCA_DES = A(3)
KPCA_DES = (LOG(2)/TEQ)
RPCA_DES = (PCA0*KPCA_DES)
RATEIN_DES = 0 
IF (T.GE.TLAG) THEN
	RATEIN_DES = (KA*GUT_DES) 
ENDIF
CC_DES = (CENTRAL_DES/V)
DPCA_DES = PCA_DES
PD_DES = (1-((EMAX*CC_DES)/(C50+CC_DES)))
DADT(1) = -(RATEIN_DES)
DADT(2) = (RATEIN_DES-((CL*CENTRAL_DES)/V))
DADT(3) = ((RPCA_DES*PD_DES)-(KPCA_DES*DPCA_DES))

$ERROR 
GUT = A(1)
CENTRAL = A(2)
PCA = A(3)
KPCA = (LOG(2)/TEQ)
RPCA = (PCA0*KPCA)
RATEIN = 0 
IF (TIME.GE.TLAG) THEN
	RATEIN = (KA*GUT) 
ENDIF
CC = (CENTRAL/V)
DPCA = PCA
PD = (1-((EMAX*CC)/(C50+CC)))

IF(DVID.EQ.1) THEN
	IPRED = CC
W = RUV_ADD+RUV_PROP*IPRED
Y = IPRED+W*EPS(1)
IRES = DV - IPRED
IWRES = IRES/W

ENDIF

IF(DVID.EQ.2) THEN
	IPRED = PCA
W = RUV_FX
Y = IPRED+W*EPS(1)
IRES = DV - IPRED
IWRES = IRES/W

ENDIF

$THETA 
( 0.01 , 0.1 , 1.0 )	;POP_CL
( 0.01 , 8.0 , 20.0 )	;POP_V
( 0.01 , 0.362 , 24.0 )	;POP_KA
( 0.01 , 1.0 , 24.0 )	;POP_TLAG
( 0.01 , 96.7 , 200.0 )	;POP_PCA0
( 0.01 , 1.2 , 10.0 )	;POP_C50
( 0.01 , 12.9 , 100.0 )	;POP_TEQ
( 0.0 , 0.05 )	;RUV_PROP
( 1.0E-4 , 0.3 )	;RUV_ADD
( 0.0 , 4.0 )	;RUV_FX
(1.0  FIX )	;POP_EMAX
(0.75  FIX )	;BETA_CL_WT
(1.0  FIX )	;BETA_V_WT

$OMEGA BLOCK(2) CORRELATION SD
(0.1 )	;PPV_CL
(0.01 )	;ETA_CL_ETA_V
(0.1 )	;PPV_V

$OMEGA 
(0.1 SD )	;PPV_KA
(0.1  FIX SD )	;PPV_TLAG
(0.1 SD )	;PPV_PCA0
(0.0  FIX SD )	;PPV_EMAX
(0.1 SD )	;PPV_C50
(0.1 SD )	;PPV_TEQ

$SIGMA 
1.0 FIX
1.0 FIX


$EST METHOD=SAEM AUTO=1 PRINT=100 CINTERVAL=30 ATOL=6 SIGL=6


$TABLE  ID TIME WT AMT DVID MDV PRED IPRED RES IRES WRES IWRES Y DV NOAPPEND NOPRINT FILE=sdtab

$TABLE  ID CL V KA TLAG PCA0 EMAX C50 TEQ ETA_CL ETA_V ETA_KA ETA_TLAG ETA_PCA0 ETA_EMAX ETA_C50 ETA_TEQ NOAPPEND NOPRINT FILE=patab

$TABLE  ID WT LOGTWT NOAPPEND NOPRINT FILE=cotab

