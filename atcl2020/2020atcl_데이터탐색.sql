-- HK HIRA 데이터 Tableau 용 가공 테이블 ... 
with plc as (
select b.cd_val sido_cd, b.cd_val_nm sido_nm, a.cd_val sigungu_cd, a.cd_val_nm sigungu_nm 
  from uni_cd_base a 
       left join uni_cd_base b on b.cd_nm = '요양기관기호지역구분코드' and substr(a.cd_val,1,2) = b.cd_val
 where a.cd_nm = '지역코드'
 order by sigungu_cd
)
select 
       concat(substr(recu_fr_ym,1,4),'/',substr(recu_fr_ym,5,2),'/01') 매출년월
      ,case when prsc_diag_tp_cd = 'C' then '원외'
            when prsc_diag_tp_cd = 'J' then '원내'
            else '##ERROR##' end 처방구분
      ,INSUP_TP_CD	보험자구분코드
      ,YADM_SNO	병원일련번호
      ,cl_cd 병원종별코드
      ,case when cl_cd =  '1' then '상급종합병원'
            when cl_cd = '11' then '종합병원'
            when cl_cd = '12' then '종합병원통합'
            when cl_cd = '21' then '병원'
            when cl_cd = '31' then '의원'
            else '##ERROR##' end 병원종별
      ,plc_cd 지역코드
      ,sido_nm 시도, sigungu_nm 시군구
      ,TOT_SBD_CNT 총병상수
      ,UNI_DIV_CD	통합분류코드
      ,case when uni_div_cd = '3640002601' then '주사제500ml'
            when uni_div_cd = '3640002610' then '주사제1000ml'
            when uni_div_cd = '3640002840' then '경구제100ml'
            when uni_div_cd = '3640006870' then '경구제SR300ml'
            else '##ERROR##' end 의약품구분
      ,DIAG_SBJT_CD	진료과목코드
      ,SHW_SBJT_CD	표시과목코드
      ,IFLD_DTL_SPC_SBJT_CD	내과세부과목코드
      ,TOT_USE_QTY_SUM	총사용량합계
      ,AMT_SUM	금액합계
  from hira_rev_base h
       inner join plc p on h.PLC_CD = p.sigungu_cd
 where cl_cd in ('1', '11', '12', '21', '31')
;


-- ------------------------------------------
-- ------------------------------------------
-- ------------------------------------------
-- HIRA - UBIST 안플로이드 100/300 데이터 비교  
select 'UBIST' 소스구분
      ,concat(substr(ym,1,4),'/',substr(ym,5,2),'/01') 청구년월
      ,'C원외' 처방구분
      ,case when prod = '안플레이드 정 100mg' then '경구제100mg'
            when prod = '안플레이드 SR 정 300mg' then '경구제SR300mg'
            else '##ERROR##' end 의약품구분 
      ,case when cl_nm = '상급종합병원' then '01상급종합병원'
            when cl_nm = '종합병원'     then '11종합병원'
            when cl_nm = '병원'         then '21병원'
            when cl_nm = '의원'         then '31의원'
            else '##ERROR##' end 병원종별 
		,plc_nm 지역명
		,p2.tableau_city 시도, p2.tableau_county 시군구           
      ,USE_QTY_SUM	사용량합계
      ,AMT_SUM	금액합계
  from HK.ubist_rev_base h
       inner join (select * from HK.tableau_map_map where map_src_cl = 'UBIST') p2 on h.plc_nm = p2.src_key_data1
 where cl_nm in ('상급종합병원','종합병원','병원','의원') and USE_QTY_SUM > 0  
union all
select 'HIRA' 소스구분
      ,concat(substr(recu_fr_ym,1,4),'/',substr(recu_fr_ym,5,2),'/01') 청구년월
      ,case when prsc_diag_tp_cd = 'C' then 'C원외'
            when prsc_diag_tp_cd = 'J' then 'J원내'
            else '##ERROR##' end 처방구분
      ,case when uni_div_cd = '3640002601' then '주사제500ml'
            when uni_div_cd = '3640002610' then '주사제1000ml'
            when uni_div_cd = '3640002840' then '경구제100mg'
            when uni_div_cd = '3640006870' then '경구제SR300mg'
            else '##ERROR##' end 의약품구분
      ,case when cl_cd =  '1' then '01상급종합병원'
            when cl_cd = '11' then '11종합병원'
            when cl_cd = '12' then '12종합병원통합'
            when cl_cd = '21' then '21병원'
            when cl_cd = '31' then '31의원'
            else '##ERROR##' end 병원종별
      ,plc_cd 지역코드
      ,tableau_city 시도, tableau_county 시군구
      ,TOT_USE_QTY_SUM	사용량합계
      ,AMT_SUM	금액합계
  from HK.hira_rev_base h
       inner join (select * from HK.tableau_map_map where map_src_cl = 'HIRA') p on h.PLC_CD = p.src_key_data1
 where cl_cd in ('1', '11', '12', '21', '31') and uni_div_cd in ('3640002840','3640006870')
; 
 