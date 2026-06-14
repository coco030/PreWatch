<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>영화 목록</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        body {
            background-color: #f8f9fa;
            color: #495057;
        }
        .container-fluid {
            padding: 32px clamp(12px, 4vw, 40px);
            overflow-x: hidden;
        }
        .section-header {
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 1rem;
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .section-header h1 {
            color: #343a40;
            font-weight: 600;
            margin-bottom: 0;
        }
        .admin-links a {
            margin-left: 1rem;
            font-size: 1rem;
            color: #6c757d;
            text-decoration: none;
            transition: color 0.2s;
        }
        .admin-links a:hover {
            color: #495057;
            text-decoration: underline;
        }
        .table-container {
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            max-width: 100%;
            overflow: visible;
        }
        .table {
            --bs-table-bg: #ffffff;
            --bs-table-hover-bg: #f8f9fa;
            width: 100%;
            min-width: 0;
            table-layout: fixed;
            margin-bottom: 0;
        }
        .table th, .table td {
            vertical-align: middle;
            word-wrap: break-word;
            padding: 8px;
            text-align: left;
        }
        .table th {
            background-color: #e9ecef;
            color: #495057;
            font-weight: 600;
            white-space: nowrap;
        }
        .table td a {
            color: #0d6efd;
            text-decoration: none;
        }
        .table td a:hover {
            text-decoration: underline;
        }
        .movie-poster-thumb {
            width: 72px;
            height: auto;
            border-radius: 5px;
            object-fit: cover;
        }
        .btn-action {
            padding: 5px 8px;
            font-size: 0.875rem;
            border-radius: 5px;
            margin-right: 2px;
            width: auto;
        }
        .btn-edit {
            background-color: #87D5AA;
            border-color: #ffffff;
            color: #fff;
        }
        .btn-delete {
            background-color: #dc3545;
            border-color: #dc3545;
            color: #fff;
        }
        .btn-warning-link {
            background-color: #ffc107;
            border-color: #ffc107;
            color: #000;
        }
        .alert {
            border-radius: 8px;
        }
        .no-data-cell {
            text-align: center;
            padding: 20px;
            color: #888;
            font-style: italic;
        }
        .link-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .table td, .table th {
            min-width: 0;
        }
        .table td {
            white-space: normal;
            overflow-wrap: anywhere;
        }

        .admin-controls-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            flex-wrap: wrap;
        }
        .admin-controls-container .btn-action,
        .admin-controls-container form {
            margin: 0 !important;
        }
        .bulk-action-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 12px;
            padding: 12px 14px;
            background: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        .bulk-action-bar label {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin: 0;
        }
        .movie-select-cell {
            width: 52px;
            max-width: 52px;
            text-align: center;
        }
        .poster-cell {
            width: 96px;
        }
        .rated-cell {
            width: 96px;
        }
        .table td.overview-cell {
            min-width: 220px;
            max-width: 280px;
            white-space: normal;
        }
        .table th.management-cell,
        .table td.management-cell {
            width: 178px;
            text-align: center;
        }
        @media (max-width: 1800px) {
            .table th.overview-cell,
            .table td.overview-cell,
            .table th.api-id-cell,
            .table td.api-id-cell {
                display: none;
            }
        }
        @media (max-width: 1300px) {
            .movie-poster-thumb {
                width: 58px;
            }
            .poster-cell {
                width: 76px;
            }
            .rated-cell {
                width: 82px;
            }
            .table th.management-cell,
            .table td.management-cell {
                width: 150px;
            }
        }
        .selected-count-text {
            color: #6c757d;
            font-weight: 600;
        }
        .list-page-controls {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
            padding: 12px 14px;
            background: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        .page-size-form {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin: 0;
        }
        .list-count-group,
        .rating-refresh-form {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .rating-refresh-form {
            margin: 0;
        }
        .missing-rated-count {
            color: #6c757d;
            font-weight: 600;
        }
        .page-size-input {
            width: 86px;
        }
        .rating-limit-input {
            width: 76px;
        }
        .pagination-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            margin-top: 18px;
            flex-wrap: wrap;
        }
        .pagination-top {
            margin-top: 0;
            margin-bottom: 12px;
        }
        .pagination-bar a,
        .pagination-bar span {
            min-width: 34px;
            padding: 6px 10px;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            color: #495057;
            text-align: center;
            text-decoration: none;
            background: #ffffff;
        }
        .pagination-bar .active-page {
            border-color: #6c63d9;
            background: #6c63d9;
            color: #ffffff;
            font-weight: 700;
        }
        .pagination-bar .disabled-page {
            color: #adb5bd;
            background: #f8f9fa;
        }
        @media (max-width: 768px) {
            .section-header {
                align-items: flex-start;
            }
            .link-group {
                justify-content: flex-start;
            }
            .list-page-controls {
                align-items: flex-start;
                flex-direction: column;
            }
        }
    </style>
</head>
<body class="bg-light">

<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<div class="container-fluid">
    <div class="section-header">
        <h1>영화 목록</h1>
        <c:if test="${userRole == 'ADMIN'}">
            <div class="link-group">
                <a href="<c:url value='/movies/new'/>" class="btn btn-sm btn-outline-secondary">새 영화 등록</a>
                <a href="<c:url value='/movies/upcoming-candidates'/>" class="btn btn-sm btn-outline-secondary">개봉예정영화 관리</a>
                <a href="<c:url value='/admin/banner-movies'/>" class="btn btn-sm btn-outline-secondary">추천 영화 관리</a>
                <a href="<c:url value='/admin/warnings/all'/>" class="btn btn-sm btn-outline-secondary">전체 주의 요소 관리</a>
            </div>
        </c:if>
    </div>

    <c:if test="${not empty param.error && param.error ne 'noSelection'}">
        <div class="alert alert-danger" role="alert">
            ${param.error == 'notFound' ? '요청하신 영화를 찾을 수 없습니다.' : (param.error == 'movieNotFound' ? '영화 정보를 찾을 수 없거나 API 호출에 실패했습니다.' : '알 수 없는 오류가 발생했습니다.')}
        </div>
    </c:if>
    <c:if test="${not empty param.error && param.error == 'noSelection'}">
        <div class="alert alert-warning" role="alert">
            삭제할 영화를 선택해주세요.
        </div>
    </c:if>
    <c:if test="${not empty param.status && param.status == 'registered'}">
        <div class="alert alert-success" role="alert">
            API에서 영화 정보가 성공적으로 등록되었습니다!
        </div>
    </c:if>
    <c:if test="${not empty param.status && param.status == 'deleted'}">
        <div class="alert alert-success" role="alert">
            선택한 영화가 삭제되었습니다.
        </div>
    </c:if>
    <c:if test="${not empty ratingRefreshMessage}">
        <div class="alert alert-info" role="alert">
            ${ratingRefreshMessage}
        </div>
    </c:if>

    <c:if test="${userRole == 'ADMIN'}">
        <div class="list-page-controls">
            <div class="list-count-group">
                <span>총 ${totalMovies}개 영화</span>
                <span class="missing-rated-count">등급 미정 ${missingRatedCount}개</span>
            </div>
            <form class="rating-refresh-form" action="<c:url value='/movies/refresh-missing-ratings'/>" method="post">
                <input type="hidden" name="page" value="${currentPage}" />
                <input type="hidden" name="size" value="${pageSize}" />
                <label for="ratingRefreshLimit">등급 보정</label>
                <input id="ratingRefreshLimit" name="limit" type="number" min="1" max="50"
                       class="form-control form-control-sm rating-limit-input" value="30" />
                <button type="submit" class="btn btn-sm btn-outline-primary">실행</button>
            </form>
            <form class="page-size-form" action="<c:url value='/movies'/>" method="get">
                <input type="hidden" name="page" value="1" />
                <label for="moviePageSize">표시 개수</label>
                <input id="moviePageSize" name="size" type="number" min="1" max="50"
                       class="form-control form-control-sm page-size-input" value="${pageSize}" />
                <button type="submit" class="btn btn-sm btn-outline-secondary">보기</button>
            </form>
        </div>
        <form id="selectedMovieDeleteForm" action="<c:url value='/movies/delete-selected'/>" method="post"
              onsubmit="return confirm('선택한 영화를 삭제하시겠습니까?');">
            <div class="bulk-action-bar">
                <label><input type="checkbox" id="selectAllMovies" /> 전체 체크</label>
                <button type="submit" class="btn btn-sm btn-danger">선택 삭제</button>
                <span id="selectedMovieCount" class="selected-count-text">선택된 영화 0개</span>
            </div>
        </form>
    </c:if>

    <div class="pagination-bar pagination-top">
        <c:choose>
            <c:when test="${currentPage > 1}">
                <a href="<c:url value='/movies?page=1&size=${pageSize}'/>">처음</a>
                <a href="<c:url value='/movies?page=${currentPage - 1}&size=${pageSize}'/>">이전</a>
            </c:when>
            <c:otherwise>
                <span class="disabled-page">처음</span>
                <span class="disabled-page">이전</span>
            </c:otherwise>
        </c:choose>

        <c:forEach var="pageNumber" begin="${startPage}" end="${endPage}">
            <c:choose>
                <c:when test="${pageNumber == currentPage}">
                    <span class="active-page">${pageNumber}</span>
                </c:when>
                <c:otherwise>
                    <a href="<c:url value='/movies?page=${pageNumber}&size=${pageSize}'/>">${pageNumber}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${currentPage < totalPages}">
                <a href="<c:url value='/movies?page=${currentPage + 1}&size=${pageSize}'/>">다음</a>
                <a href="<c:url value='/movies?page=${totalPages}&size=${pageSize}'/>">마지막</a>
            </c:when>
            <c:otherwise>
                <span class="disabled-page">다음</span>
                <span class="disabled-page">마지막</span>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="table-responsive table-container">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <c:if test="${userRole == 'ADMIN'}">
                        <th class="movie-select-cell">선택</th>
                    </c:if>
                    <th class="poster-cell">포스터</th>
                    <th>제목</th>
                    <th>감독</th>
                    <th>연도</th>
                    <th>장르</th>
                    <th class="rated-cell">등급</th>
                    <th class="overview-cell">개요</th>
                    <th class="api-id-cell">TMDb ID</th>
                    <c:if test="${userRole == 'ADMIN'}">
                        <th class="management-cell">관리</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="movie" items="${movies}">
                    <tr>
                        <c:if test="${userRole == 'ADMIN'}">
                            <td class="movie-select-cell">
                                <input type="checkbox" class="movie-select-checkbox" name="movieIds" value="${movie.id}" form="selectedMovieDeleteForm" />
                            </td>
                        </c:if>
                        <td class="poster-cell">
                            <c:set var="posterSrc">
                                <c:choose>
                                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                ${movie.posterPath}
                                            </c:when>
                                            <c:when test="${fn:startsWith(movie.posterPath, '/resources/')}">
                                                ${pageContext.request.contextPath}${movie.posterPath}
                                            </c:when>
                                            <c:otherwise>
                                                https://image.tmdb.org/t/p/w342${movie.posterPath}
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <img src="${posterSrc}" alt="${movie.title} 포스터" class="movie-poster-thumb" />
                        </td>
                        <td>
                            <a href="<c:url value='/movies/${movie.id}'/>">${movie.title}</a>
                        </td>
                        <td>${movie.director}</td>
                        <td>${movie.year}</td>
                        <td>${movie.genre}</td>
                        <td class="rated-cell">
                            <c:choose>
                                <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                                <c:otherwise>등급 미정</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="overview-cell">${fn:substring(movie.overview, 0, 30)}...</td>
                        <td class="api-id-cell">${movie.apiId}</td>
                        <c:if test="${userRole == 'ADMIN'}">
                            <td class="management-cell">
                                <div class="admin-controls-container">
                                    <a href="<c:url value='/movies/${movie.id}/edit'/>" class="btn btn-sm btn-edit btn-action">수정</a>
                                    <a href="<c:url value='/admin/warnings/${movie.id}' />" class="btn btn-sm btn-warning-link btn-action">주의요소</a>
                                    <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" onsubmit="return confirm('정말로 이 영화를 삭제하시겠습니까?');" style="display:inline-block;">
                                        <button type="submit" class="btn btn-sm btn-delete btn-action">삭제</button>
                                    </form>
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
                <c:if test="${empty movies}">
                    <tr>
                        <td colspan="${userRole == 'ADMIN' ? '10' : '8'}" class="no-data-cell">등록된 영화가 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <div class="pagination-bar">
        <c:choose>
            <c:when test="${currentPage > 1}">
                <a href="<c:url value='/movies?page=1&size=${pageSize}'/>">처음</a>
                <a href="<c:url value='/movies?page=${currentPage - 1}&size=${pageSize}'/>">이전</a>
            </c:when>
            <c:otherwise>
                <span class="disabled-page">처음</span>
                <span class="disabled-page">이전</span>
            </c:otherwise>
        </c:choose>

        <c:forEach var="pageNumber" begin="${startPage}" end="${endPage}">
            <c:choose>
                <c:when test="${pageNumber == currentPage}">
                    <span class="active-page">${pageNumber}</span>
                </c:when>
                <c:otherwise>
                    <a href="<c:url value='/movies?page=${pageNumber}&size=${pageSize}'/>">${pageNumber}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${currentPage < totalPages}">
                <a href="<c:url value='/movies?page=${currentPage + 1}&size=${pageSize}'/>">다음</a>
                <a href="<c:url value='/movies?page=${totalPages}&size=${pageSize}'/>">마지막</a>
            </c:when>
            <c:otherwise>
                <span class="disabled-page">다음</span>
                <span class="disabled-page">마지막</span>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const selectAllMovies = document.getElementById('selectAllMovies');
    const movieCheckboxes = Array.from(document.querySelectorAll('.movie-select-checkbox'));
    const selectedMovieCount = document.getElementById('selectedMovieCount');
    function updateSelectedMovieCount() {
        const checkedCount = movieCheckboxes.filter(function (item) {
            return item.checked;
        }).length;
        if (selectedMovieCount) {
            selectedMovieCount.textContent = '선택된 영화 ' + checkedCount + '개';
        }
        if (selectAllMovies) {
            selectAllMovies.checked = checkedCount > 0 && checkedCount === movieCheckboxes.length;
            selectAllMovies.indeterminate = checkedCount > 0 && checkedCount < movieCheckboxes.length;
        }
    }
    if (selectAllMovies) {
        selectAllMovies.addEventListener('change', function () {
            movieCheckboxes.forEach(function (checkbox) {
                checkbox.checked = selectAllMovies.checked;
            });
            updateSelectedMovieCount();
        });

        movieCheckboxes.forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                updateSelectedMovieCount();
            });
        });
        updateSelectedMovieCount();
    }
</script>
</body>
</html>
