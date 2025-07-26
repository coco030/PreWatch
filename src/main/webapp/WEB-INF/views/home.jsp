<%--
    파일명: home.jsp
    설명:
        이 JSP 파일은 홈페이지입니다.

    목적:
        - 사용자가 웹사이트에 처음 접속했을 때 보여주는 화면.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("홈 뷰 진입"); %> 
<html>
<head>
    <title>PreWatch: 나만의 영화 피디아</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body>

    <%-- 헤더 영역 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <%-- 메인 영역 --%>
    <main>
        <div>
            <jsp:include page="/WEB-INF/views/layout/main.jsp" />
        </div>
    </main>
	<!-- 통계 표시 박스  -->
    <div class="stats-display-box">
        <p>영화 리뷰 <strong id="reviewCount" data-count="${globalStats.totalReviewContentCount}">0</strong>개가 쌓였어요.</p>
        <p>영화 만족도 별점 <strong id="ratingCount" data-count="${globalStats.totalUserRatingCount}">0</strong>개가 쌓였어요.</p>
        <p>영화 폭력성 평가가 <strong id="violenceCount" data-count="${globalStats.totalViolenceScoreCount}">0</strong>개 쌓였어요.</p>
 	<!--예시 : <p>영화 xxx 평가가 <strong id="특정함수Count" data-count="${globalStats.total특정함수}">0</strong>개 쌓였어요.</p> -->
    
    </div>   

<script>
    // 숫자 카운트업 애니메이션 함수
    function animateCountUp(element) {
        const finalCount = parseInt(element.dataset.count, 10);
        if (isNaN(finalCount)) {
            element.innerText = '0';
            return;
        }

        // 애니메이션 시간 (밀리초 단위). 
        const duration = 5000; // 5초
        let startTimestamp = null;

        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const currentCount = Math.floor(progress * finalCount);
            
            element.innerText = currentCount.toLocaleString(); // 1000단위 콤마(,) 추가
            
            if (progress < 1) {
                window.requestAnimationFrame(step);
            } else {
                element.innerText = finalCount.toLocaleString(); // 애니메이션 종료 후 최종값 보정
            }
        };
        window.requestAnimationFrame(step);
    }

    // 페이지 로드가 완료되면, 각 통계 숫자에 애니메이션 적용
    document.addEventListener('DOMContentLoaded', function() {
        animateCountUp(document.getElementById('reviewCount'));
        animateCountUp(document.getElementById('ratingCount'));
        animateCountUp(document.getElementById('violenceCount'));
  //  예시:   animateCountUp(document.getElementById('특정함수'));
    });
    </script>
<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 
<div class="d-block d-md-none" style="height: 80px;"></div> -->
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>