<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("영화 등록 폼 진입"); %>
<html>
<head>
    <title>영화 ${movie.id == null ? '등록' : '수정'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        body {
            background-color: #f8f9fa; /* 연한 회색 배경 */
            color: #495057; /* 기본 텍스트 색상 */
        }
        .form-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background-color: #ffffff; /* 흰색 배경 */
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        .form-container h1 {
            color: #343a40;
            font-weight: 600;
            margin-bottom: 30px;
            text-align: center;
        }
        .form-label {
            font-weight: 500;
            color: #495057;
            margin-bottom: 8px;
        }
        .form-control, .form-select {
            border: 1px solid #ced4da;
            border-radius: 8px;
            padding: 10px 15px;
            transition: border-color 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
        }
        .form-control:focus {
            border-color: #86b7fe;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        }
        
        .btn-action {
            padding: 10px 20px;
            font-size: 1rem;
            border-radius: 8px;
            transition: background-color 0.2s ease-in-out, border-color 0.2s ease-in-out;
        }
        .btn-primary {
            background-color: #007bff; /* 요청하신 파란색 배경으로 변경 */
            border-color: #007bff; /* 테두리도 같은 색으로 변경 */
            color: #fff;
        }
        .btn-primary:hover {
            background-color: #0056b3; /* hover 시 조금 더 어두운 파란색으로 변경 */
            border-color: #0056b3;
        }
        .btn-secondary {
            background-color: #e9ecef;
            border-color: #e9ecef;
            color: #495057;
        }
        .btn-secondary:hover {
            background-color: #dae0e5;
            border-color: #d3d9df;
        }
        .alert {
            border-radius: 8px;
        }
        .imdb-info {
            font-size: 0.9rem;
            color: #6c757d;
        }
        .imdb-info a {
            color: #0d6efd;
            text-decoration: none;
        }
        .imdb-info a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<div class="container form-container">
    <h1 class="mb-4">${movie.id == null ? '영화 등록' : '영화 수정'}</h1>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">
            ${errorMessage}
        </div>
    </c:if>

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
        <div class="mb-3">
            <label for="apiId" class="form-label">IMDb 코드:</label>
            <div class="d-flex align-items-center">
                <input type="text" class="form-control d-inline-block w-auto me-2" id="apiId" name="apiId" value="${movie.apiId}" placeholder="예: tt1234567" style="min-width: 160px;" />
                <small class="form-text text-muted imdb-info">
                    (※ 코드만 입력하면 영화 정보 자동완성 및 출연진까지 동시 등록)
                    <a href="https://www.imdb.com/calendar/" target="_blank">IMDb에서 코드 찾기</a>
                </small>
            </div>
        </div>
        <div class="mb-3">
            <label for="title" class="form-label">제목:</label>
            <input type="text" class="form-control" id="title" name="title" value="${movie.title}" />
        </div>
        <div class="mb-3">
            <label for="director" class="form-label">감독:</label>
            <input type="text" class="form-control" id="director" name="director" value="${movie.director}" />
        </div>
        <div class="row mb-3">
            <div class="col-md-6">
                <label for="year" class="form-label">연도:</label>
                <input type="number" class="form-control" id="year" name="year" value="${movie.year}" />
            </div>
            <div class="col-md-6">
                <label for="releaseDate" class="form-label">개봉일:</label>
                <input type="date" class="form-control" id="releaseDate" name="releaseDate" value="${movie.releaseDate}" />
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-md-4">
                <label for="genre" class="form-label">장르:</label>
                <input type="text" class="form-control" id="genre" name="genre" value="${movie.genre}" />
            </div>
            <div class="col-md-4">
                <label for="rated" class="form-label">연령 등급:</label>
                <input type="text" class="form-control" id="rated" name="rated" value="${movie.rated}" />
            </div>
            <div class="col-md-4">
                <label for="runtime" class="form-label">상영 시간:</label>
                <input type="text" class="form-control" id="runtime" name="runtime" value="${movie.runtime}" />
            </div>
        </div>
        <div class="mb-3">
            <label for="overview" class="form-label">개요:</label>
            <textarea class="form-control" id="overview" name="overview" rows="5">${movie.overview}</textarea>
        </div>
        <div class="mb-4">
            <label for="posterImage" class="form-label">포스터:</label>
            <input type="file" class="form-control" id="posterImage" name="posterImage" />
        </div>

        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
            <button type="submit" class="btn btn-primary btn-action me-md-2">${movie.id == null ? '등록' : '수정'}</button>
            <a href="<c:url value='/movies'/>" class="btn btn-secondary btn-action">목록으로</a>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>