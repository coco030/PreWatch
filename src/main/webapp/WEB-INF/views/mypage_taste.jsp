<%@ page language="java" contentType="text-html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>나의 취향 분석 리포트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/layout.css">
    <style>
    .person-info img {
		    width: 80px;
		    height: 80px; /* 80x80으로 세로 맞추는 게 원형에 더 잘 맞음 */
		    object-fit: cover;
		    border-radius: 50%; /* 기존 8px → 50%로 변경 */
		    margin-right: 20px;
		    border: 2px solid #e0e0e0; /* 연한 테두리(선택, 미적용 가능) */
		    background: #f4f4f4; /* 비어있을 때 회색 배경(선택) */
		}
        .taste-container { max-width: 800px; margin: 40px auto; padding: 40px; background-color: #fff; border: 1px solid #e0e0e0; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); font-family: 'Noto Sans KR', sans-serif; }
        .page-title { text-align: center; font-size: 2em; font-weight: 700; color: #333; margin-bottom: 10px; }
        .taste-title-box { text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 8px; margin-bottom: 30px; }
        .taste-title { font-size: 1.7em; color: #2980b9; margin: 0; }
        .report-section { margin-bottom: 25px; }
       
        .report-content { font-size: 1.1em; line-height: 1.8; color: #555; padding-left: 10px; }
        .keyword { display: inline-block; background-color: #eaf2f8; color: #3498db; padding: 5px 12px; border-radius: 15px; margin-right: 8px; font-weight: 500; }
        .initial-message { text-align: center; font-size: 1.2em; color: #777; padding: 40px 0; }
        .person-info { display: flex; align-items: center; margin-bottom: 15px; border-left: 4px solid #f0f0f0; padding-left: 15px;}
        .person-info img { width: 80px; height: 120px; object-fit: cover; border-radius: 8px; margin-right: 20px; }
        .insight-text { color: #27ae60; font-weight: 500; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="taste-container">
        <h1 class="page-title">My Taste Profile</h1>

        <c:choose>
            <c:when test="${not tasteReport.isInitialReport()}">
                <div class="taste-title-box"><h2 class="taste-title">"${tasteReport.title}"</h2></div>

                <div class="report-section">
                    <h3 class="section-title">#️⃣ 당신의 취향 키워드</h3>
                    <div class="report-content">
                        <c:forEach var="genre" items="${tasteReport.keywords.topGenres}"><span class="keyword">#${genre}</span></c:forEach>
                        <span class="keyword">${tasteReport.keywords.style}</span>
                    </div>
                </div>

                <div class="report-section">
                    <h3 class="section-title">📊 상세 취향 분석</h3>
                    <div class="report-content">
                        <c:if test="${not empty tasteReport.analysis.strengths}">
                            <p><strong>[강점]</strong> 당신은 일반 관객보다 
                                <c:forEach var="s" items="${tasteReport.analysis.strengths}" varStatus="status"><strong>${s}</strong><c:if test="${not status.last}">, </c:if></c:forEach>
                                요소가 강한 영화에서 큰 만족감을 얻습니다.</p>
                        </c:if>
                        <c:if test="${not empty tasteReport.analysis.weaknesses}">
                            <p><strong>[주의]</strong> 
                                <c:forEach var="w" items="${tasteReport.analysis.weaknesses}" varStatus="status"><strong>${w}</strong><c:if test="${not status.last}">, </c:if></c:forEach>
                                요소가 두드러지는 영화는 불편하게 느낄 수 있으니 참고하세요.</p>
                        </c:if>
                        <c:if test="${empty tasteReport.analysis.strengths and empty tasteReport.analysis.weaknesses}">
                            <p>• 모든 요소를 고르게 즐기는 균형잡힌 시각을 가졌습니다. 뚜렷한 호불호보다는 영화의 전체적인 완성도를 중요하게 생각합니다.</p>
                        </c:if>
                        <c:if test="${not empty tasteReport.analysis.specialInsight}">
                            <p><strong>[특별한 발견]</strong> ${tasteReport.analysis.specialInsight}</p>
                        </c:if>
                    </div>
                </div>
                
                <div class="report-section">
    <h3 class="section-title">🎬 영화 속 인물과의 인연</h3>
    <div class="report-content">

        <!-- 감독 정보 -->
        <c:if test="${not empty tasteReport.frequentPersons.mostReviewedDirector}">
            <c:set var="mrd" value="${tasteReport.frequentPersons.mostReviewedDirector}" />
            <c:set var="hrd" value="${tasteReport.frequentPersons.highlyRatedDirector}" />
            <div class="person-info">
                <c:if test="${not empty mrd.imageUrl}">
                    <img src="https://image.tmdb.org/t/p/w300${mrd.imageUrl}" alt="${mrd.name}">
                </c:if>
                <div>
                    <p>당신이 평가한 영화들 중 <strong>${mrd.name}</strong> 감독의 작품이 가장 많았습니다.</p>
                    <c:if test="${not empty hrd and mrd.id == hrd.id}">
                        <p class="insight-text">그리고 실제로도 이 감독의 작품들에 <strong>8점 이상</strong>의 높은 점수를 가장 많이 부여했습니다.</p>
                    </c:if>
                    <c:if test="${not empty hrd and mrd.id != hrd.id}">
                        <p class="insight-text">참고로, 8점 이상을 가장 많이 받은 작품들의 감독은 <strong>${hrd.name}</strong>입니다.</p>
                    </c:if>
                </div>
            </div>
        </c:if>

	        <!-- 배우 정보 -->
	        <c:if test="${not empty tasteReport.frequentPersons.mostReviewedActor}">
	            <c:set var="mra" value="${tasteReport.frequentPersons.mostReviewedActor}" />
	            <c:set var="hra" value="${tasteReport.frequentPersons.highlyRatedActor}" />
	            <div class="person-info">
	                <c:if test="${not empty mra.imageUrl}">
	                    <img src="https://image.tmdb.org/t/p/w300${mra.imageUrl}" alt="${mra.name}">
	                </c:if>
	                <div>
	                    <p>가장 자주 등장한 배우는 <strong>${mra.name}</strong>입니다.</p>
	                    <c:if test="${not empty hra and mra.id == hra.id}">
	                        <p class="insight-text">이 배우가 출연한 영화들에 <strong>8점 이상</strong>의 점수를 가장 많이 주셨네요.</p>
	                    </c:if>
	                    <c:if test="${not empty hra and mra.id != hra.id}">
	                        <p class="insight-text">참고로, 8점 이상을 가장 많이 받은 영화에 출연한 배우는 <strong>${hra.name}</strong>였습니다.</p>
	                    </c:if>
	                </div>
	            </div>
	        </c:if>
	
	    </div>
	</div>


                <div class="report-section">
                    <h3 class="section-title">⭐ 당신의 영화 선택 패턴</h3>
                    <div class="report-content">
                        <ul>
                            <c:if test="${not empty tasteReport.preferences.preferredYear}">
                                <li><strong>선호 시대:</strong> <strong>${tasteReport.preferences.preferredYear}</strong>에 대한 선호도가 높습니다.</li>
                            </c:if>
                            <c:if test="${not empty tasteReport.preferences.preferredRuntime}">
                                <li><strong>선호 길이:</strong> <strong>${tasteReport.preferences.preferredRuntime}</strong>에 깊게 몰입하는 경향이 있습니다.</li>
                            </c:if>
                            <c:if test="${not empty tasteReport.activityPattern}">
                                <li><strong>감상 패턴:</strong> <strong>${tasteReport.activityPattern}</strong>.</li>
                            </c:if>
                        </ul>
                    </div>
                </div>

                <div class="report-section">
                    <h3 class="section-title">💡 다음 영화 선택 가이드</h3>
                    	<p><strong>[안전한 선택]</strong> ${tasteReport.recommendation.safeBet}</p>
                        <p><strong>[새로운 도전]</strong> ${tasteReport.recommendation.adventurousChoice}</p>
                </div>

            </c:when>
            <c:otherwise>
                <div class="taste-title-box"><h2 class="taste-title">"${tasteReport.title}"</h2></div>
                <div class="initial-message"><p>${tasteReport.initialMessage}</p></div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
</body>
</html>