<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<div class="container">
    <h2 class="section-title">최근 등록된 영화</h2>
    <div class="movie-grid">
        <c:choose>
            <c:when test="${not empty movies}">
                <c:forEach var="movie" items="${movies}">
                    <div class="movie-card">
                        <a href="<c:url value='/movies/${movie.id}'/>">
                            <c:set var="posterSrc">
                                <c:choose>
                                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                        <c:if test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                            ${movie.posterPath}
                                        </c:if>
                                        <c:if test="${not (fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://'))}">
                                            ${pageContext.request.contextPath}${movie.posterPath}
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        ${pageContext.request.contextPath}/resources/images/default_poster.jpg
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <img src="${posterSrc}" alt="${movie.title} 포스터" />
                            <h3>${movie.title}</h3>
                            <p>${movie.year} | ${movie.genre}</p>
                            <p>평점: ${movie.rating}</p>
                        </a>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p>아직 등록된 영화가 없습니다. <a href="<c:url value='/movies/new'/>">새 영화를 등록</a>하거나 <a href="<c:url value='/movies'/>">영화 목록</a>에서 API를 통해 가져와보세요!</p>
            </c:otherwise>
        </c:choose>
    </div>
