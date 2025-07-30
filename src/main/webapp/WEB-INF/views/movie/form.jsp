<%--
    파일명: form.jsp
    설명:
        이 JSP 파일은 새로운 영화를 등록하거나 기존 영화 정보를 수정하는 데 사용되는 폼 페이지입니다.
        `movie` 도메인 객체를 기반으로 입력 필드를 채우며, `movie.id` 값의 유무에 따라 "등록" 또는 "수정" 모드로 동작합니다.
        포스터 이미지 업로드 기능도 포함합니다.

    목적:
        - 관리자가 영화 정보를 생성(C)하고 수정(U)하는 기능을 위한 사용자 인터페이스를 제공합니다.
        - 하나의 폼으로 등록과 수정을 모두 처리하여 코드의 재사용성을 높입니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%System.out.println("영화 등록 폼 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<html>
<head>
<title>영화 ${movie.id == null ? '등록' : '수정'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
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
 	<%-- 25.07.30 coco030 추가 : 기능 이걸 넣으면  TMDB api를 써서 배우 매핑하고 출연진도 동시 저장 --%>
    <label for="apiId">IMDb 코드:</label>
	<input type="text" name="apiId" value="${movie.apiId}" placeholder="예: tt1234567" style="width: 160px;" />
	<span style="color: #666; font-size: 0.97em;">
	    (※ 코드만 입력하면 영화 정보 자동완성 및 출연진까지 동시 등록)
	    <a href="https://www.imdb.com/" target="_blank" style="color:#0066cc; text-decoration:underline; margin-left:7px;">
	        IMDb에서 코드 찾기
	    </a>
	</span>
	<br/>
	<%-- 25.07.30 coco030 추가 끝 --%>
	제목: <input type="text" name="title" value="${movie.title}" /><br/>
    감독: <input type="text" name="director" value="${movie.director}" /><br/>
    연도: <input type="number" name="year" value="${movie.year}" /><br/>
    장르: <input type="text" name="genre" value="${movie.genre}" /><br/>
    연령 등급: <input type="text" name="rated" value="${movie.rated}" /><br/>
    상영 시간: <input type="text" name="runtime" value="${movie.runtime}" /><br/>
	<label for="releaseDate">개봉일:</label>
	<input type="date" name="releaseDate"
       value="${movie.releaseDate}" /><br/>
    개요: <textarea name="overview">${movie.overview}</textarea><br/>

    포스터: <input type="file" name="posterImage" /><br/>

    <button type="submit">${movie.id == null ? '등록' : '수정'}</button>
</form>

<a href="<c:url value='/movies'/>">목록으로</a>
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>