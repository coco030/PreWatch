<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %> 

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 마이페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
    .mypage-wrapper {
        --primary-color: #6c5ce7; 
        background-color: #f8f9fa;
        font-family: 'Noto Sans KR', sans-serif;
        padding: 2rem 0;
    }
    .section-header {
        display: flex; justify-content: space-between; align-items: center;
        background-color: #fff; border-radius: 0.5rem; padding: 1rem 1.5rem;
        margin-bottom: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .section-header .title { font-size: 1.2rem; font-weight: 600; }
    .btn-taste-report {
        background-color: var(--primary-color); color: white; border: none; font-weight: 500;
        padding: 0.5rem 1rem; border-radius: 0.375rem; text-decoration: none; transition: background-color 0.2s;
    }
    .btn-taste-report:hover { background-color: #5849c4; color: white; }
    .review-card {
        background-color: #fff; border-radius: 0.75rem; border: 1px solid #e9ecef;
        transition: box-shadow 0.2s ease, border-color 0.2s ease;
       
    }
    .review-card:hover { 
        box-shadow: 0 4px 12px rgba(0,0,0,0.08); 
        border-color: var(--primary-color); 
    }
    .review-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-color: var(--primary-color); }
    .card-main-content { display: flex; align-items: center; }
    .poster-container { padding: 1rem; flex: 0 0 150px; }
    .poster-img { width: 100%; border-radius: 0.375rem; }
    .info-container { padding: 1.5rem; flex-grow: 1; }
    .movie-meta-info { color: #6c757d; font-size: 0.9rem; }
    .movie-meta-info p { margin-bottom: 0.25rem; }

    /* 점수 표시 영역  */
    .score-container { 
        padding: 1.5rem; flex: 0 0 240px; /* 너비 살짝 줄임 */
        border-left: 1px solid #e9ecef; 
        display: flex; align-items: center; justify-content: center; /* 중앙 정렬 */
    }
    .score-grid { 
        display: grid; 
        grid-template-columns: 1fr 1fr; /* 2열 그리드 */
        gap: 1.5rem 2rem; /* 세로, 가로 간격 조정 */
        width: 100%;
    }
    .score-item { text-align: center; }
    .score-item .icon { font-size: 1.2rem; margin-bottom: 0.25rem; display: block; color: #adb5bd; }
    .score-item .label { font-size: 0.85rem; color: #495057; font-weight: 500; }
    .score-item .score-value { font-size: 1.2rem; font-weight: 700; color: var(--primary-color); }
    .score-item .text-satisfaction { color: #ffc107; }
    .score-item .text-violence { color: #dc3545; }
    .score-item .text-horror { color: #343a40; }
    .score-item .text-sexual { color: #fd7e14; }

    /* 리뷰 표시 영역 */
    .review-content-wrapper{
    border-top: 1px solid #e9ecef; 
    padding: 1rem 1.5rem;
    background-color: #fafbfd; 
    font-size: 0.95rem; 
    line-height: 1.7;

    border-bottom-left-radius: 0.75rem;  /* 부모와 동일한 값으로 왼쪽 아래 모서리 둥글게 */
    border-bottom-right-radius: 0.75rem; /* 부모와 동일한 값으로 오른쪽 아래 모서리 둥글게 */
}
    
    .review-content-wrapper.expandable {
        cursor: pointer;
    }
    .review-text.collapsed {
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: var(--line-clamp, 2); /* 2를 CSS 변수로 변경 (기본값은 2) */
    -webkit-box-orient: vertical;
    -webkit-mask-image: none;
}

    .toggle-review-btn {
        background: none; border: none; color: var(--primary-color);
        font-weight: 500; cursor: pointer; padding: 0.25rem 0;
        pointer-events: none; 
    }

    .pagination .page-item.active .page-link { background-color: var(--primary-color); border-color: var(--primary-color); font-weight: 700; color: white; }
    .pagination .page-link { color: #6c757d; }
    .pagination .page-item:not(.disabled) .page-link:hover { color: var(--primary-color); }
    .pagination .page-item:not(.disabled) .page-link.prev-next { color: var(--primary-color); font-weight: 500; }
    @media (max-width: 991.98px) {
        .card-main-content { flex-direction: column; align-items: stretch; }
        .poster-container { flex-basis: auto; text-align: center; }
        .poster-img { max-width: 150px; }
        .score-container { border-left: none; border-top: 1px solid #e9ecef; flex-basis: auto; }
    }
</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<div class="mypage-wrapper">
    <div class="container">
        <div class="section-header">
            <div class="title"><i class="fas fa-film me-2 text-secondary"></i>${sessionScope.loginMember.id}님의 영화 기록</div>
            <a href="<c:url value='/member/mypage_taste'/>" class="btn-taste-report"><i class="fas fa-chart-pie me-1"></i>나의 취향 분석</a>
        </div>

        <c:forEach var="review" items="${myReviews}">
            <c:set var="movie" value="${movieMap[review.movieId]}" />
            
 		<div class="card review-card mb-3">

                <a href="${pageContext.request.contextPath}/movies/${movie.id}" class="text-decoration-none text-dark">
                    <div class="card-main-content">
                        <!-- 포스터 -->
                        <div class="poster-container">
                             <c:if test="${not empty movie.posterPath}"><img src="${movie.posterPath}" class="img-fluid poster-img" alt="포스터" /></c:if>
                        </div>
                        <!-- 영화 정보 -->
                        <div class="info-container">
                            <h4 class="card-title fw-bold mb-2">${movie.title}</h4>
                            <div class="movie-meta-info">
                                <c:if test="${not empty movie.genre}"><p><i class="fas fa-tag fa-fw me-2"></i>${movie.genre}</p></c:if>
                                <c:if test="${not empty movie.releaseDate}"><p><i class="fas fa-calendar-alt fa-fw me-2"></i>${movie.releaseDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))} 개봉</p></c:if>
                            </div>
                        </div>
                        <!-- 점수 -->
                        <div class="score-container">
                            <div class="score-grid">
                                <div class="score-item"><i class="fas fa-star icon text-satisfaction"></i><span class="label">만족도</span><br><span class="score-value"><c:out value="${review.userRating}" default="0"/></span></div>
                                <div class="score-item"><i class="fas fa-burst icon text-violence"></i><span class="label">폭력성</span><br><span class="score-value"><c:out value="${review.violenceScore}" default="0"/></span></div>
                                <div class="score-item"><i class="fas fa-ghost icon text-horror"></i><span class="label">공포성</span><br><span class="score-value"><c:out value="${review.horrorScore}" default="0"/></span></div>
                                <div class="score-item"><i class="fas fa-heart icon text-sexual"></i><span class="label">선정성</span><br><span class="score-value"><c:out value="${review.sexualScore}" default="0"/></span></div>
                            </div>
                        </div>
                    </div>
                </a> 
                
                <!-- 리뷰 영역 -->
                <c:if test="${not empty review.reviewContent or not empty review.tags}">
                        <div class="review-content-wrapper">
                            <c:if test="${not empty review.reviewContent}">
                                <p class="review-text fst-italic mb-1">${review.reviewContent}</p>
                                <button type="button" class="toggle-review-btn d-none">더보기</button>
                            </c:if>
                            <c:if test="${not empty review.tags}">
                                <p class="mb-0 mt-2"><span class="badge bg-light text-secondary">${fn:replace(review.tags, ',', ' ')}</span></p>
                            </c:if>
                        </div>
                    </c:if>
                </div>
        </c:forEach>
        <!-- Pagination -->
        <nav aria-label="리뷰 페이지 이동" class="mt-4">
             <ul class="pagination justify-content-center">
                <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>'"><a class="page-link prev-next" href="?page=${currentPage - 1}">이전</a></li>
                <c:forEach var="i" begin="1" end="${totalPages}"><li class="page-item <c:if test='${i == currentPage}'>active</c:if>'"><a class="page-link" href="?page=${i}">${i}</a></li></c:forEach>
                <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>'"><a class="page-link prev-next" href="?page=${currentPage + 1}">다음</a></li>
            </ul>
        </nav>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll('.review-text').forEach(function(reviewText) {
        const style = window.getComputedStyle(reviewText);
        const lineHeight = parseFloat(style.lineHeight);
        
        // 보여줄 줄 수 조절
        const lineClamp = 3; 
        
        const maxHeight = lineHeight * lineClamp;

        // 내용이 잘렸을 경우에만 '더보기' 
        if (reviewText.scrollHeight > maxHeight) {
            const reviewWrapper = reviewText.parentElement; 
            const toggleButton = reviewWrapper.querySelector('.toggle-review-btn');
            
            if(reviewWrapper && toggleButton) {

                reviewWrapper.classList.add('expandable'); 
                toggleButton.classList.remove('d-none');
                reviewText.classList.add('collapsed');
                reviewText.style.setProperty('--line-clamp', lineClamp);

               //클릭 이벤트를 버튼이 아닌, 리뷰 영역 전체(.review-content-wrapper)에 추가
                reviewWrapper.addEventListener('click', function(event) {

                    const currentReviewText = this.querySelector('.review-text');
                    const currentToggleButton = this.querySelector('.toggle-review-btn');
                    
                    currentReviewText.classList.toggle('collapsed');
                    
                    // 버튼 텍스트 변경
                    currentToggleButton.textContent = currentReviewText.classList.contains('collapsed') ? '더보기' : '접기';
                });
            }
        }
    });
});
</script>
</body>
</html>