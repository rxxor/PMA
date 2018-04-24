
* Get address and spec info from CRD HCP dataservice ;

%include '~/SASCODES/General/control.sas' ;

	proc sql;                                                                                                                               
	connect to oracle (user=&usrid. orapw=&passwd. path="prd287");                                                                                                                   
	create table shankar.d0710_crdhcp as select * from connection to oracle                                                                                                            
	(                                                                                                                                    
	select
		b.PARTY_ID                  	PRFSNL_ID,
		a.PHYSCN_RFRNC_NMBR            	PRSN_ID, 
		a.IMS_AFLTN_ID                 	AFLTN_ID,
		a.IMS_AFLTN_SRC_ID             	AFLTN_SRC_ID,
		a.IMS_PRSCRBR_ID              	IMS_PRSCRBR_ID,   
		a.FRST_NM                      	,
		a.MDL_NM                       	,
		a.LST_NM                       	,
		a.IMS_MAJOR_SPCLTY_CD          	IMS_MJR_SPCLTY_CD,
		a.IMS_MAJOR_SPCLTY_DESC_TXT    	IMS_MJR_SPCLTY_DESC_TXT,  
		a.LILLY_MAJOR_SPCLTY_CD        	LY_MJR_SPCLTY_CD, 
		a.LILLY_MAJOR_SPCLTY_DESC_TXT  	LY_MJR_SPCLTY_DESC_TXT,
		a.PRFSNL_DSGNTN_CD             	PRFSNL_DSGNTN_CD,
		b.CITY_NM                      	,
		b.CNTRY_NM                      ,
		b.DEA_NBR                       DEA_NBR,
		b.PRMRY_ADRS_FLG                PRMRY_ADRS_FLG,
		b.LGL_ADRS_FLG                  LGL_ADRS_FLG,
		b.ADRS_LINE_1                   LN_1_ADRS_TXT,
		b.ADRS_LINE_2                   LN_2_ADRS_TXT,
		b.PSTL_CD                       ,
		b.PSTL_CD_EXTNSN                PSTL_CD_EXTNSN_TXT,
		b.ST_NM							,
		b.end_Dt             
	FROM         		
		CRD_HCP_DATA_SERVICE a,
		CRD_HCP_ADDRESS_DATA_SERVICE b
	WHERE        		
		a.ROWID_OBJECT = b.PARTY_ID 
	order by 				
		b.PARTY_ID ,a.PHYSCN_RFRNC_NMBR
							
	);
	DISCONNECT FROM ORACLE; QUIT;


