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
    /* 이전과 동일한 CSS 스타일 */
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
    .heart-icon { font-size: 1.1rem; color: #dc3545; }
    .heart-icon.disabled { color: #adb5bd; cursor: not-allowed; }
    .no-movies-message a { font-weight: bold; color: #0d6efd; }
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
                                        <%-- 상세 페이지와 달리, 이 페이지의 하트는 항상 '찜 취소' 기능만 수행 --%>
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

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // ⭐ 기존 AJAX 로직을 재사용하여 찜 목록 제거 기능을 구현한 toggleCart 함수
    function toggleCart(element) {
        if (element.classList.contains('disabled')) {
            alert('로그인한 사용자만 이용할 수 있습니다.');
            return;
        }

        const movieId = element.dataset.movieId;
        const cardToRemove = $('#movie-card-' + movieId); // jQuery로 제거할 카드 요소 선택
        const icon = $(element);
        
        // 아이콘을 즉시 비활성화하여 중복 클릭 방지
        icon.css('pointer-events', 'none');

        // 팀의 기존 AJAX 엔드포인트 사용
        $.ajax({
            url: '${pageContext.request.contextPath}/movies/' + movieId + '/toggleCart',
            type: 'POST',
            success: function(response) {
                // 서버로부터 '제거됨' 상태를 받으면 카드를 화면에서 제거
                if (response.status === 'removed') {
                    cardToRemove.fadeOut(400, function() {
                        $(this).remove(); // 애니메이션 후 DOM에서 완전히 제거
                        
                        // 모든 카드가 제거되었는지 확인하고 메시지 표시
                        if ($('#movie-grid-row .col').length === 0) {
                            $('#wishlist-container').html(
                                `<div class="alert alert-info text-center no-movies-message" role="alert">
                                    찜한 영화가 없습니다. <a href="<c:url value='/'/>" class="alert-link">홈으로 돌아가</a> 새로운 영화를 탐색해보세요!
                                </div>`
                            );
                        }
                    });
                } else {
                    // 이 페이지에서는 'added' 상태가 오면 안되지만, 예외 상황에 대비해 아이콘 상태를 원상 복구
                    alert("예상치 못한 응답입니다. 페이지를 새로고침합니다.");
                    location.reload();
                }
            },
            error: function(xhr) {
                alert("찜 취소 중 오류가 발생했습니다: " + (xhr.responseJSON ? xhr.responseJSON.message : "서버 오류"));
                // 실패 시 아이콘 다시 활성화
                icon.css('pointer-events', 'auto');
            }
        });
    }
    </script>
</body>
</html>