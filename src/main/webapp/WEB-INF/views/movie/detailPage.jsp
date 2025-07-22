<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<%System.out.println("영화 상세페이지 진입"); %>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" crossorigin="anonymous" />
    <style>
        .favorite-button-wrapper {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            margin-top: 20px;
        }
        .favorite-button {
            background-color: #f44336;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-bottom: 10px;
        }
        .favorite-button:hover {
            background-color: #d32f2f;
        }
        .favorite-button.disabled,
        .favorite-button.processing {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .like-count-detail {
            font-size: 1.2em;
            color: #555;
            font-weight: bold;
        }
    </style>
</head> 

<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<%-- 폭력성 주의문구 --%>
<c:import url="/review/sensitivity">
    <c:param name="movieId" value="${movie.id}" />
</c:import>   

<h1>${movie.title}</h1>

<c:if test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
    <c:set var="posterSrc">
        <c:choose>
            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                ${movie.posterPath}
            </c:when>
            <c:otherwise>
                ${pageContext.request.contextPath}${movie.posterPath}
            </c:otherwise>
        </c:choose>
    </c:set>
    <img src="${posterSrc}" alt="${movie.title} 포스터" style="max-width: 300px; height: auto;" /><br/>
</c:if>
<c:if test="${empty movie.posterPath or movie.posterPath eq 'N/A'}">
    <p>(이미지 없음)</p>
</c:if>

<p>감독: ${movie.director}</p>
<p>연도: ${movie.year}</p>
<p>장르: ${movie.genre}</p>

<p>평점:
    <c:choose>
        <c:when test="${movie.rating == 0.0}">
            N/A
        </c:when>
        <c:otherwise>
            <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
        </c:otherwise>
    </c:choose>
    / 10.0
</p>

<p>폭력성 평균:
    <c:choose>
        <c:when test="${movie.violence_score_avg == 0.0}">
            N/A
        </c:when>
        <c:otherwise>
            <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" />
        </c:otherwise>
    </c:choose>
    / 10.0
</p>

<p>개요: ${movie.overview}</p>

<hr>

<%-- 찜 버튼 및 개수 --%>
<div class="favorite-button-wrapper">
    <c:if test="${empty movie.id}">
        <button class="favorite-button disabled" disabled>찜 기능 사용 불가 (DB에 없는 영화)</button>
        <span class="like-count-detail">총 0명 찜</span>
    </c:if>
    <c:if test="${not empty sessionScope.loginMember && sessionScope.userRole == 'MEMBER' && not empty movie.id}">
        <button class="favorite-button" id="toggleFavoriteBtn"
                data-movie-id="${movie.id}"
                data-is-liked="${movie.isLiked()}">
            <c:choose>
                <c:when test="${movie.isLiked()}">찜 목록에서 제거</c:when>
                <c:otherwise>찜 목록에 추가</c:otherwise>
            </c:choose>
        </button>
        <span class="like-count-detail" id="likeCountDetail">총 ${movie.likeCount}명 찜</span>
    </c:if>
    <c:if test="${empty sessionScope.loginMember || sessionScope.userRole == 'ADMIN'}">
        <button class="favorite-button disabled" disabled>
            <c:choose>
                <c:when test="${empty sessionScope.loginMember}">로그인 후 찜 가능</c:when>
                <c:otherwise>관리자 계정은 찜 기능 불가</c:otherwise>
            </c:choose>
        </button>
        <span class="like-count-detail">총 ${movie.likeCount}명 찜</span>
    </c:if>
</div>

<hr>

<%-- 태그 표시 --%>
<c:import url="/review/tags">
    <c:param name="movieId" value="${movie.id}" />
</c:import>

<%-- 리뷰 작성 폼 --%>
<c:if test="${not empty sessionScope.loginMember}">
    <c:import url="/review/form">
        <c:param name="movieId" value="${movie.id}" />
    </c:import>
</c:if>

<%-- 리뷰 리스트 --%>
<c:import url="/review/list">
    <c:param name="movieId" value="${movie.id}" />
</c:import>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    $(document).ready(function() {
        $(document).off('click', '#toggleFavoriteBtn').on('click', '#toggleFavoriteBtn', function() {
            const movieId = $(this).data('movie-id');
            const button = $(this);
            const likeCountDetailSpan = $('#likeCountDetail');

            if (button.hasClass('processing')) return;

            button.addClass('processing').prop('disabled', true);

            $.ajax({
                url: '${pageContext.request.contextPath}/movies/' + movieId + '/toggleCart',
                type: 'POST',
                success: function(response) {
                    if (response.status === 'added') {
                        button.text('찜 목록에서 제거');
                        button.data('is-liked', true);
                        alert("찜 목록에 추가되었습니다.");
                    } else if (response.status === 'removed') {
                        button.text('찜 목록에 추가');
                        button.data('is-liked', false);
                        alert("찜 목록에서 제거되었습니다.");
                    }
                    if (response.newLikeCount !== undefined) {
                        likeCountDetailSpan.text(`총 ${response.newLikeCount}명 찜`);
                    }
                },
                error: function(xhr) {
                    alert("찜 처리 중 오류가 발생했습니다: " + xhr.responseText);
                },
                complete: function() {
                    button.removeClass('processing');
                    if (button.data('is-liked') !== undefined) {
                        button.prop('disabled', false);
                    }
                }
            });
        });
    });
</script>
</body>
</html>
