<%-- admin/bannerMovieManage.jsp (7-24 오후12:41 추가 된 코드) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>추천 영화 관리</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body>
    <div class="container">
        <h2>관리자 - 수동 추천 영화 관리</h2>

        <c:if test="${not empty successMessage}">
            <div class="message success-message">${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message error-message">${errorMessage}</div>
        </c:if>

        <div class="section-box">
            <h3>추천 영화 추가</h3>
            <form action="<c:url value='/admin/banner-movies/add'/>" method="post" class="movie-selection">
                <label for="movieSelect">추천할 영화 선택:</label>
                <select id="movieSelect" name="movieId" required>
                    <option value="">-- 영화를 선택하세요 --</option>
                    <c:forEach var="movie" items="${allMovies}">
                        <option value="${movie.id}">${movie.title} (${movie.year})</option>
                    </c:forEach>
                </select>
                <button type="submit">추가</button>
            </form>
        </div>

        <div class="section-box">
            <h3>현재 수동 추천 영화 목록</h3>
            <c:choose>
                <c:when test="${not empty currentAdminBannerMovies}">
                    <ul class="current-movies">
                        <c:forEach var="movie" items="${currentAdminBannerMovies}">
                            <li>
                                <span>${movie.title} (${movie.year})</span>
                                <form action="<c:url value='/admin/banner-movies/delete'/>" method="post" onsubmit="return confirm('정말로 이 영화를 추천 목록에서 삭제하시겠습니까?');">
                                    <input type="hidden" name="movieId" value="${movie.id}">
                                    <button type="submit">삭제</button>
                                </form>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p>현재 수동 추천 영화로 등록된 영화가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>