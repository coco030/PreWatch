<%@ page language="java" contentType="text-html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>나의 취향 분석 리포트</title>
    
    <%-- 전체 레이아웃을 위한 CSS  --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/layout.css">
    
    <%-- 이 페이지의 콘텐츠를 보기 좋게 꾸미기 위한 스타일 --%>
    <style>
        .taste-container { max-width: 800px; margin: 40px auto; padding: 40px; background-color: #fff; border: 1px solid #e0e0e0; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); font-family: 'Noto Sans KR', sans-serif; }
        .page-title { text-align: center; font-size: 2em; font-weight: 700; color: #333; margin-bottom: 10px; }
        .taste-title-box { text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 8px; margin-bottom: 30px; }
        .taste-title { font-size: 1.7em; color: #2980b9; margin: 0; }
        .report-section { margin-bottom: 25px; }
        .section-title { font-size: 1.3em; font-weight: 600; color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
        .report-content { font-size: 1.1em; line-height: 1.8; color: #555; padding-left: 10px; }
        .keyword { display: inline-block; background-color: #eaf2f8; color: #3498db; padding: 5px 12px; border-radius: 15px; margin-right: 8px; font-weight: 500; }
        .initial-message { text-align: center; font-size: 1.2em; color: #777; padding: 40px 0; }
    </style>
</head>
<body>
    <%-- 공통 헤더 포함 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="taste-container">
        <h1 class="page-title">My Taste Profile</h1>

        <c:choose>
            <c:when test="${analysisComplete}">
                <div class="taste-title-box">
                    <h2 class="taste-title">"${tasteReport.title}"</h2>
                </div>

                <%-- 1. 취향 키워드 --%>
                <div class="report-section">
                    <h3 class="section-title">#️⃣ 당신의 취향 키워드</h3>
                    <div class="report-content">
                        <c:forEach var="genre" items="${tasteReport.topGenres}">
                            <span class="keyword">#${genre}</span>
                        </c:forEach>
                        <span class="keyword">${tasteReport.userStyle}</span>
                    </div>
                </div>

                <%-- 2. 상세 취향 분석 --%>
                <div class="report-section">
                    <h3 class="section-title">📊 상세 취향 분석</h3>
                    <div class="report-content">
                        <c:if test="${not empty tasteReport.strengthKeywords}">
                            <p><strong>[강점]</strong> 당신은 일반 관객보다 
                                <c:forEach var="s" items="${tasteReport.strengthKeywords}" varStatus="status">
                                    <strong>${s}</strong><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                                요소가 강한 영화에서 큰 만족감을 얻습니다.</p>
                        </c:if>
                        <c:if test="${not empty tasteReport.weaknessKeywords}">
                            <p><strong>[주의]</strong> 
                                <c:forEach var="w" items="${tasteReport.weaknessKeywords}" varStatus="status">
                                    <strong>${w}</strong><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                                요소가 두드러지는 영화는 불편하게 느낄 수 있으니 참고하세요.</p>
                        </c:if>
                        <c:if test="${not empty tasteReport.specialInsight}">
                            <p><strong>[특별한 발견]</strong> ${tasteReport.specialInsight}</p>
                        </c:if>
                    </div>
                </div>
                
                <%-- 3. 영화 선택 스타일 (선호 인물, 연도, 시간) --%>
                <div class="report-section">
                    <h3 class="section-title">🎬 당신의 영화 선택 스타일</h3>
                    <div class="report-content">
                        <ul>
                            <c:if test="${not empty tasteReport.favoritePersonName}">
                                <li><strong>선호 인물:</strong> 당신은 <strong>${tasteReport.favoritePersonName}</strong>(${tasteReport.favoritePersonRole})의 작품에 높은 만족도를 보였습니다.</li>
                            </c:if>
                            <c:if test="${not empty tasteReport.preferredYear}">
                                <li><strong>선호 시대:</strong> <strong>${tasteReport.preferredYear}</strong>에 대한 선호도가 높습니다.</li>
                            </c:if>
                            <c:if test="${not empty tasteReport.preferredRuntime}">
                                <li><strong>선호 길이:</strong> <strong>${tasteReport.preferredRuntime}</strong>을 가진 영화에 깊게 몰입하는 경향이 있습니다.</li>
                            </c:if>
                            <c:if test="${not empty tasteReport.activityPattern}">
                                <li><strong>감상 패턴:</strong> <strong>${tasteReport.activityPattern}</strong>.</li>
                            </c:if>
                        </ul>
                    </div>
                </div>

                <%-- 4. 다음 영화 선택 가이드 --%>
                <div class="report-section">
                    <h3 class="section-title">💡 다음 영화 선택 가이드</h3>
                    <div class="report-content">
                        <p><strong>[안전한 선택]</strong> ${tasteReport.bestBetRecommendation}</p>
                        <p><strong>[새로운 도전]</strong> ${tasteReport.adventurousRecommendation}</p>
                    </div>
                </div>

            </c:when>

            <%-- Case 2: 분석 전인 경우 (리뷰 5개 미만) --%>
            <c:otherwise>
                <div class="taste-title-box">
                    <h2 class="taste-title">"${memberInfo.tasteTitle}"</h2>
                </div>
                <div class="initial-message">
                    <p>${memberInfo.tasteReport}</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 공통 푸터 포함 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
</body>
</html>