<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("홈 뷰 진입"); %> 
<html>
<head>
    <title>PreWatch: 나만의 영화 피디아</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        /* 07-31: main.jsp에서 옮겨온 캘린더 관련 스타일 */
        body { font-family: Arial, sans-serif; }
        .calendar-container { width: 60%; margin: 20px auto; border: 1px solid #ccc; padding: 10px; }
        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            font-size: 24px;
            padding: 0 10px;
        }
        .calendar-month-display { /* 07-31: 클래스명 변경 반영 및 스타일 추가 */
            flex-grow: 1;
            text-align: center;
            font-size: 1.5em;
            font-weight: bold;
        }    
        .calendar-nav { /* 07-31: float 속성 제거 (Flexbox 사용) */
            font-size: 16px;
            margin: 0 5px;
        }
        .calendar-nav button {
            background-color: #f0f0f0;
            border: 1px solid #ccc;
            padding: 5px 10px;
            cursor: pointer;
            font-size: 0.9em;
            border-radius: 4px;
        }
        .calendar-nav button:hover {
            background-color: #e0e0e0;
        }
        .calendar-table { width: 100%; border-collapse: collapse; }
        .calendar-table th { background-color: #f2f2f2; }
        .calendar-table td { /* 07-31: 너비 고정 및 overflow 속성 추가 */
            border: 1px solid #eee;
            padding: 5px;
            text-align: center;
            vertical-align: top;
            height: 120px;
            width: calc(100% / 7);
            overflow: hidden;
            box-sizing: border-box;
        }
        .day-number { font-weight: bold; margin-bottom: 5px; display: block; text-align: right; }
        .movie-poster-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            align-items: flex-start;
            gap: 2px;
            max-width: 100%;
        }
        .movie-poster { /* 07-31: 고정 픽셀 크기 적용 */
            width: 80px;
            height: 100px;
            object-fit: cover;
        }
        .movie-poster.small { width: 45%; } /* 07-31: 필요시 픽셀 값으로 재조정 고려 */
        .movie-poster.smaller { width: 30%; } /* 07-31: 필요시 픽셀 값으로 재조정 고려 */
        .movie-link { text-decoration: none; color: inherit; display: block; }
        .today { background-color: #ffe; }
        .other-month { color: #aaa; }
    </style>
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
        <p>영화 댓글 <strong id="reviewCount" data-count="${globalStats.totalReviewContentCount}">0</strong>개가 쌓였어요.</p>
        <p>영화 만족도 평가가 <strong id="ratingCount" data-count="${globalStats.totalUserRatingCount}">0</strong>개가 쌓였어요.</p>
        <p>영화 폭력성 평가가 <strong id="violenceCount" data-count="${globalStats.totalViolenceScoreCount}">0</strong>개 쌓였어요.</p>
        <p>영화 공포성 평가가 <strong id="ratingCount" data-count="${globalStats.totalUserRatingCount}">0</strong>개가 쌓였어요.</p>
        <p>영화 선정성 평가가 <strong id="violenceCount" data-count="${globalStats.totalViolenceScoreCount}">0</strong>개 쌓였어요.</p>       
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
        const duration = 3000; // 3초
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
    });
    </script>
<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 
<div class="d-block d-md-none" style="height: 80px;"></div> -->
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>