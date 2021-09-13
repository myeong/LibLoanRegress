도서관 대출 회귀분석을 위한 데이터 준비
=============
### 데이터 범위
	2015년-2018년, 수도권(경기, 인천, 서울) 시군구 66개 지역 

### 데이터 리스트
1. 독립변인(사회적 박탈지수)
	1) EQ5D 지표 = 보건 (2015-2018) 
		출처: https://kosis.kr/statHtml/statHtml.do?orgId=177&tblId=DT_117075_HEALTH_EQ_5D&conn_path=I2 통계청
	2) 국민연금공단_자격 시구신고 평균소득월액 = 경제 (2015-2018) 
		출처: https://www.data.go.kr/data/3046077/fileData.do 공공데이터 포털: 국민연금공단
	3) 성, 연령 및 교육정도별 인구(6세이상,내국인)-시군구 = 교육 (2015)
		출처: https://kosis.kr/statHtml/statHtml.do?orgId=101&tblId=DT_1PM1501&conn_path=I2 통계청
	4) 사회적 박탈지수
		EQ5D(보건), 평균소득월액(경제), 교육정도별 인구(교육) PCA 실행
2. 통제 변인
	1) 주민등록연앙인구 = 총인구, 여성인구 (2015-2018)
		출처: https://kosis.kr/statHtml/statHtml.do?orgId=101&tblId=DT_1B040M5&conn_path=I2 통계청
	2) 버스정류장, 노선, 지하철역, 지하철 노선 = 교통 (2021년 기준)
		출처: (경기, 인천 버스정류장 노선 정보) https://www.data.go.kr/iim/api/selectAPIAcountView.do 공공데이터포털:국토부
		출처: (서울 버스정류장 노선 정보) http://data.seoul.go.kr/dataList/OA-1095/F/1/datasetView.do 서울 열린 데이터 광장
                         출처: (지하철 정보) https://www.data.go.kr/data/15013205/standard.do 공공데이터 포털
	3) 행정구역 현황= 도시면적 (2015-2018)
		출처:  https://kosis.kr/statHtml/statHtml.do?orgId=315&tblId=TX_315_2009_H1009&conn_path=I2
	4) 공공도서관 국내장서수, 도서관 연식, 면적 (2015-2018)
		출처: https://www.libsta.go.kr/ 문화체육관광부:국가도서관통계시스템

3. 종속 변인
	1) 도서관 총대출권수, 분야별 대출권수 (2015-2018)
		출처: https://www.libsta.go.kr/ 문화체육관광부:국가도서관통계시스템

4. 기타
	1) Qgis를 위한 SHP
		출처: http://www.gisdeveloper.co.kr/?p=2332 (경기도 구단위를 시단위로 올리기 위해 일부 수정 및 교통정보 매칭하기 위해 사용)
	2) 행정동 법정동 코드
		출처: http://kssc.kostat.go.kr/ksscNew_web/kssc/common/CommonBoardList.do?gubun=1&strCategoryNameCode=019&strBbsId=kascrr&categoryMenu=014 통계청 (데이터들간 매칭을 위해)

### 데이터 생성 과정
1. 독립 변인 데이터 수집 (경제, 보건, 교육)
	데이터 수집 -> 데이터 검토 -> 데이터 선정
2. 사회적 박탈 지수 생성
	경제, 보건, 교육 데이터를 standard scale한 뒤 PCA 실행 (40~50% 재현율)
3.  종속, 통제 변인 수집
	버스노선, 정류장, 지하철 역, 노선 데이터 수집 후 Qgis를 통해 시군구 매칭 후 데이터 매칭을 위해 행정동 법정동 코드사용 
	시군구 면적, 연앙인구, 도서관 데이터 수집

### 최상위 폴더 설명
1. data 폴더 = 회귀분석을 위한 데이터 세트
2. ipynb 폴더 = python jupyter ipynb 파일 (순서별로 숫자로 라벨링)
3. html 폴더 = folium library를 통해 만든 지표 지도 결과 html 파일

### 회귀 데이터 세트 위한 data 폴더 설명
1.  /data/result/ , 데이터 전체 과정 결과 데이터 세트
2. /data/temporary_storage/ , 데이터 생성 과정에서 나온 데이터 세트
3. /data/geojson/ , folium library 시각화를 위한 geojson
4. /data/korea_city/ , 한국 행정동 법정동 코드 데이터
5. /data/public_library_statics/ , 문체부 국가도서관 통계시스템 2015-2018 데이터
6. /data/SHP/ , 버스정류장, 지하철 등 위치 데이터와 읍면동 데이터를 매칭하기 위한 SHP 파일
7. /data/statics/ , 통계청 데이터 세트
8. /data/traffic/ , 버스정류장, 지하철, 도로노드링크 데이터 세트

### 최종 데이터 세트
1. /data/result/result.csv , 시군구별 2015-2018 데이터
2. /data/result/3_library_info.csv , 2015-2018 각 도서관의 정보 데이터

### 시각화
1. folium을 통한 사회적 지표, 대출 비율 시각화
	대출 비율은 크게 구분이 안가서 log를 사용하여 구분을 하였음