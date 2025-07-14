<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head><title>영화 ${movie.id == null ? '등록' : '수정'}</title></head>
<body>
<h1>${movie.id == null ? '영화 등록' : '영화 수정'}</h1>
<c:set var="formActionUrl">
    <c:choose>
        <c:when test="${movie.id == null}">
            <c:url value='/movies'/>
        </c:when>
        <c:otherwise>
            <c:url value="/movies/${movie.id}/edit"/>
        </c:otherwise>
    </c:choose>
</c:set>
<form action="${formActionUrl}" method="post" enctype="multipart/form-data">
    제목: <input type="text" name="title" value="${movie.title}" /><br/>
    감독: <input type="text" name="director" value="${movie.director}" /><br/>
    연도: <input type="number" name="year" value="${movie.year}" /><br/>
    장르: <input type="text" name="genre" value="${movie.genre}" /><br/>
    평점: <input type="number" name="rating" value="${movie.rating}" step="0.1" min="0.0" max="10.0" /><br/>
    잔혹도: <input type="number" name="violence_score_avg" value="${movie.violence_score_avg}" step="0.1" min="0.0" max="10.0" /><br/>
    개요: <textarea name="overview">${movie.overview}</textarea><br/>
    포스터: <input type="file" name="posterImage" /><br/>
    <button type="submit">${movie.id == null ? '등록' : '수정'}</button>
</form>
<a href="<c:url value='/movies'/>">목록으로</a>
</body>
</html>