<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%System.out.println("wishlist 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<title>나의 찜 영화 목록</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
    body { background-color: #f8f9fa; }
    .page-title { font-weight: bold; color: #343a40; border-bottom: 3px solid #dee2e6; padding-bottom: 0.5rem; }
    .movie-card { transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; border: 1px solid #e9ecef; position: relative; }
    .movie-card:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1); }
    .movie-card .card-img-top { width: 100%; aspect-ratio: 2 / 3; object-fit: cover; }
    .movie-card .card-body { display: flex; flex-direction: column; padding: 0.8rem; }
    .movie-card .card-title { font-size: 0.9rem; font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .movie-card .card-text { font-size: 0.8rem; color: #6c757d; margin-bottom: 0.25rem; }
    .card-link { text-decoration: none; color: inherit; }
    .heart-info-container { position: absolute; top: 8px; right: 8px; z-index: 10; background-color: rgba(255, 255, 255, 0.8); border-radius: 50%; padding: 6px; display: flex; align-items: center; justify-content: center; cursor: pointer; }
    .heart-icon { 
        font-size: 1.1rem; 
        color: #dc3545;
        /* ⭐ 하트 아이콘 색상 변경 시 부드러운 전환 효과 추가 */
        transition: color 0.2s ease-in-out;
    }
    .heart-icon.far { 
        color: #6c757d; 
    }
    .heart-icon.disabled { color: #adb5bd; cursor: not-allowed; }
    .no-movies-message a { font-weight: bold; color: #0d6efd; }
    
        /* ✅ 페이지네이션 강제 정렬 */
    .pagination {
        display: flex !important;
        flex-wrap: nowrap !important;
        justify-content: center;
        gap: 4px;
    }
    .page-link {
        border: 1px solid #dee2e6;
        color: #495057;
        padding: 6px 12px;
    }
    .page-item.active .page-link {
        background-color: #6f42c1;
        border-color: #6f42c1;
        color: #fff;
    }
    .page-item.disabled .page-link {
        color: #adb5bd;
        pointer-events: none;
    }

    /* ✅ 모바일에서 최대 6개 카드만 보여주기 */
    #movie-grid-row .col:nth-child(n+7) {
        display: none;
    }

    @media (min-width: 768px) {
        #movie-grid-row .col {
            display: block !important;
        }
    }
</style>
</head>
<body>
    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <main class="container my-5">
        <h2 class="page-title mb-4">나의 찜 영화 목록</h2>
        <div id="wishlist-container">
            <c:choose>
                <c:when test="${not empty likedMovies}">
                    <div class="row row-cols-2 row-cols-sm-3 row-cols-lg-4 g-3" id="movie-grid-row">
                        <c:forEach var="movie" items="${likedMovies}">
                            <div class="col" id="movie-card-${movie.id}">
                                <div class="card h-100 movie-card shadow-sm">
                                    <div class="heart-info-container">
                                        <i class="heart-icon fas fa-heart <c:if test='${empty sessionScope.loginMember}'>disabled</c:if>"
                                           data-movie-id="${movie.id}"
                                           onclick="toggleCart(this)"></i>
                                    </div>
                                    <a href="<c:url value='/movies/${movie.id}'/>" class="card-link">
                                        <c:set var="posterSrc">
                                            <c:choose>
                                                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                                    <c:if test="${fn:startsWith(movie.posterPath, 'http')}">${movie.posterPath}</c:if>
                                                    <c:if test="${not fn:startsWith(movie.posterPath, 'http')}">${pageContext.request.contextPath}${movie.posterPath}</c:if>
                                                </c:when>
                                                <c:otherwise>${pageContext.request.contextPath}/resources/images/default_poster.jpg</c:otherwise>
                                            </c:choose>
                                        </c:set>
                                        <img src="${posterSrc}" class="card-img-top" alt="${movie.title} 포스터" />
                                    </a>
                                    <div class="card-body">
                                        <a href="<c:url value='/movies/${movie.id}'/>" class="card-link">
                                            <h5 class="card-title" title="${movie.title}">${movie.title}</h5>
                                        </a>
                                        <p class="card-text">${movie.year} | ${movie.genre}</p>
                                        <p class="card-text">⭐ <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
                                        <p class="card-text">🩸 <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></p>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-info text-center no-movies-message" role="alert">
                        찜한 영화가 없습니다. <a href="<c:url value='/'/>" class="alert-link">홈으로 돌아가</a> 새로운 영화를 탐색해보세요!
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
        <!-- 페이지네이션 -->
    <nav aria-label="페이지 이동">
        <ul class="pagination justify-content-center">
            <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                <a class="page-link" href="?page=${currentPage - 1}">이전</a>
            </li>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                    <a class="page-link" href="?page=${i}">${i}</a>
                </li>
            </c:forEach>

            <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>">
                <a class="page-link" href="?page=${currentPage + 1}">다음</a>
            </li>
        </ul>
    </nav>

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    

    <script>
    // ⭐ 페이지 로드 완료 후 스크립트 실행
    $(document).ready(function() {
        
        // ⭐ 사용자가 찜 취소 동작을 직관적으로 이해하도록 돕는 UI 개선 로직
        // .heart-info-container에 마우스를 올리거나 뗄 때 이벤트 처리
        $('#wishlist-container').on({
            mouseenter: function() {
                // 마우스를 올리면, 내부의 채워진 하트를 빈 하트로 변경
                $(this).find('.heart-icon.fas').removeClass('fas').addClass('far');
            },
            mouseleave: function() {
                // 마우스를 떼면, 내부의 빈 하트를 다시 채워진 하트로 복원
                $(this).find('.heart-icon.far').removeClass('far').addClass('fas');
            }
        }, '.heart-info-container'); // 이벤트 위임: 동적으로 추가/제거되는 요소에도 이벤트가 적용되도록 함

    });


    // ⭐ 기존 찜 제거 기능 함수 (변경 없음)
    function toggleCart(element) {
        if (element.classList.contains('disabled')) {
            alert('로그인한 사용자만 이용할 수 있습니다.');
            return;
        }

        const movieId = element.dataset.movieId;
        const cardToRemove = $('#movie-card-' + movieId);
        const iconContainer = $(element).closest('.heart-info-container');
        
        // 중복 클릭을 막기 위해 컨테이너의 이벤트를 즉시 비활성화
        iconContainer.css('pointer-events', 'none');

        // 팀의 기존 AJAX 엔드포인트 사용
        $.ajax({
            url: '${pageContext.request.contextPath}/movies/' + movieId + '/toggleCart',
            type: 'POST',
            success: function(response) {
                if (response.status === 'removed') {
                    cardToRemove.fadeOut(400, function() {
                        $(this).remove();
                        if ($('#movie-grid-row .col').length === 0) {
                            $('#wishlist-container').html(
                                `<div class="alert alert-info text-center no-movies-message" role="alert">
                                    찜한 영화가 없습니다. <a href="<c:url value='/'/>" class="alert-link">홈으로 돌아가</a> 새로운 영화를 탐색해보세요!
                                </div>`
                            );
                        }
                    });
                } else {
                    alert("예상치 못한 응답입니다. 페이지를 새로고침합니다.");
                    location.reload();
                }
            },
            error: function(xhr) {
                alert("찜 취소 중 오류가 발생했습니다: " + (xhr.responseJSON ? xhr.responseJSON.message : "서버 오류"));
                // 실패 시 이벤트 다시 활성화
                iconContainer.css('pointer-events', 'auto');
            }
        });
    }
    </script>
</body>
</html>