<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>영화 검색</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>?v=home-overview-20260611">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
        }

        .container {
            width: 90%;
            max-width: 1320px;
            margin: 20px auto;
            padding: 24px;
            background-color: #fff;
            border: 1px solid #e7ecf3;
            border-radius: 10px;
            box-shadow: 0 12px 34px rgba(15, 23, 42, 0.08);
        }

        .search-result-header {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 22px;
            padding-bottom: 16px;
            border-bottom: 1px solid #d8dee8;
        }

        .search-result-label {
            display: block;
            color: #6c63d9;
            font-size: 0.86rem;
            font-weight: 800;
        }

        .search-result-header h2 {
            margin: 4px 0 0;
            color: #1f2937;
            font-size: 2.1rem;
            font-weight: 850;
            letter-spacing: 0;
            word-break: keep-all;
            overflow-wrap: anywhere;
        }

        .search-result-count {
            flex: 0 0 auto;
            min-height: 34px;
            padding: 7px 13px;
            border-radius: 999px;
            background: #f2f4ff;
            color: #5d68d9;
            font-size: 0.9rem;
            font-weight: 800;
        }

        .error-message {
            color: red;
            font-weight: bold;
            margin-bottom: 15px;
        }

        .no-results {
            color: #777;
            font-style: italic;
        }
        
        .movie-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .movie-table th, .movie-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
            vertical-align: middle;
        }

        .movie-table th {
            background-color: #333;
            color: white;
            font-weight: bold;
            text-transform: uppercase;
        }

        .movie-table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .movie-table tbody tr:hover {
            background-color: #f1f1f1;
        }

        .movie-poster {
            max-width: 80px;
            height: auto;
            display: block;
            border-radius: 4px;
        }

        .action-form {
            display: inline;
        }

        .action-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 12px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 4px;
            transition-duration: 0.4s;
        }

        .action-button:hover {
            background-color: #0056b3;
        }

        .back-link {
            text-align: right;
            margin-bottom: 15px;
        }

        .back-button {
            padding: 8px 16px;
            background-color: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .back-button:hover {
            background-color: #5a6268;
        }

        a.title-link {
            color: #007bff;
            text-decoration: none;
            font-weight: bold;
        }

        a.title-link:hover {
            text-decoration: underline;
        }

        .user-search-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-top: 20px;
        }

        .user-search-card {
            min-width: 0;
            cursor: pointer;
        }

        .user-search-poster {
            position: relative;
            aspect-ratio: 2 / 3;
            overflow: hidden;
            border-radius: 6px;
            background: #e9ecef;
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.12);
        }

        .user-search-poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.18s ease;
        }

        .user-search-card:hover .user-search-poster img {
            transform: scale(1.04);
        }

        .user-search-poster.is-poster-protected img {
            filter: blur(14px) saturate(0.7);
            transform: scale(1.08);
        }

        .poster-privacy-cover {
            position: absolute;
            inset: 0;
            z-index: 2;
            display: none;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            gap: 8px;
            padding: 12px;
            background: rgba(248, 250, 252, 0.76);
            text-align: center;
        }

        .user-search-poster.is-poster-protected .poster-privacy-cover {
            display: flex;
        }

        .user-search-poster.is-poster-protected .user-search-overlay {
            display: none;
        }

        .poster-privacy-cover span {
            color: #334155;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .poster-privacy-view {
            min-height: 30px;
            padding: 0 12px;
            border: 1px solid #cbd5e1;
            border-radius: 999px;
            background: #fff;
            color: #475569;
            font-size: 0.76rem;
            font-weight: 800;
            cursor: pointer;
        }

        .user-search-overlay {
            position: absolute;
            inset: 0;
            z-index: 3;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            background: rgba(0, 0, 0, 0.42);
            opacity: 0;
            transition: opacity 0.16s ease;
        }

        .user-search-card:hover .user-search-overlay,
        .user-search-card:focus-within .user-search-overlay {
            opacity: 1;
        }

        .poster-action-button {
            width: 42px;
            height: 42px;
            border: 0;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #212529;
            background: rgba(255, 255, 255, 0.92);
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            cursor: pointer;
            transition: transform 0.16s ease, background-color 0.16s ease, color 0.16s ease;
        }

        .poster-action-button:hover,
        .poster-action-button:focus {
            transform: translateY(-2px);
            background: #ffffff;
            color: #6c63d9;
        }

        .poster-action-button.is-liked {
            color: #dc3545;
        }

        .search-like-button:hover,
        .search-like-button:focus,
        .search-like-button.is-hover-preview,
        .search-like-button.is-liked {
            background: #fff1f2;
            color: #dc3545;
        }

        .poster-action-button:disabled {
            cursor: wait;
            opacity: 0.75;
        }

        .user-search-meta {
            margin-top: 9px;
            font-size: 0.88rem;
            line-height: 1.35;
        }

        .user-search-rated {
            color: #6c757d;
            font-size: 0.78rem;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-search-genre {
            color: #868e96;
            font-size: 0.76rem;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-search-title {
            display: block;
            color: #212529;
            font-weight: 700;
            text-decoration: none;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-search-title:hover {
            color: #6c63d9;
        }

        .search-more-wrapper {
            margin-top: 24px;
            text-align: center;
        }

        .search-more-button {
            min-width: 180px;
            border: 1px solid #ced4da;
            border-radius: 999px;
            background: #fff;
            color: #495057;
            padding: 10px 18px;
            font-weight: 600;
            cursor: pointer;
            transition: border-color 0.16s ease, color 0.16s ease, box-shadow 0.16s ease;
        }

        .search-more-button:hover,
        .search-more-button:focus {
            border-color: #6c63d9;
            color: #6c63d9;
            box-shadow: 0 6px 18px rgba(108, 99, 217, 0.16);
        }

        .search-more-button:disabled {
            cursor: wait;
            opacity: 0.7;
        }

        .register-toolbar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin: 12px 0;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 6px;
            background: #fafafa;
        }

        .register-toolbar label {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin: 0;
        }

        .register-toolbar button {
            border: 1px solid #6c757d;
            background: #fff;
            color: #333;
            border-radius: 4px;
            padding: 7px 12px;
            cursor: pointer;
        }

        .register-progress {
            color: #666;
            font-size: 14px;
        }

        .register-check-cell {
            text-align: center;
            width: 56px;
        }

        .register-status {
            display: block;
            margin-top: 6px;
            color: #6c757d;
            font-size: 13px;
        }

        .action-button.is-complete {
            background-color: #6c757d;
            cursor: default;
        }

        .import-toast {
            position: fixed;
            right: 24px;
            bottom: 24px;
            z-index: 2000;
            max-width: 360px;
            padding: 12px 16px;
            border-radius: 6px;
            background: #25282d;
            color: #fff;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18);
            opacity: 0;
            transform: translateY(10px);
            pointer-events: none;
            transition: opacity 0.18s ease, transform 0.18s ease;
        }

        .import-toast.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .import-toast.is-error {
            background: #b02a37;
        }

        @media (max-width: 720px) {
            .container {
                width: 96%;
                padding: 12px;
            }

            .user-search-grid {
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 10px;
            }

            .poster-action-button {
                width: 34px;
                height: 34px;
            }

            .search-result-header {
                align-items: flex-start;
            }

            .search-result-header h2 {
                font-size: 1.55rem;
            }

            .user-search-meta {
                font-size: 0.78rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="container" data-register-panel data-import-url="<c:url value='/movies/import-api-detail/ajax'/>">
        <c:if test="${userRole eq 'ADMIN'}">
            <p class="back-link"><a href="<c:url value='/movies'/>" class="back-button">내 영화 관리페이지로 돌아가기</a></p>
            <p class="back-link"><a href="<c:url value='/movies/upcoming-candidates'/>" class="back-button">개봉예정영화 관리</a></p>
        </c:if> 

        <c:if test="${searchPerformed}">
            <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
                <p class="error-message">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
            </c:if>

            <div class="search-result-header">
                <div>
                    <span class="search-result-label">검색 결과</span>
                    <h2><c:out value="${query}" /></h2>
                </div>
                <c:if test="${not empty apiMovies}">
                    <span class="search-result-count">${fn:length(apiMovies)}편</span>
                </c:if>
            </div>
            <c:if test="${empty apiMovies}">
                <p class="no-results">검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
            </c:if>

            <c:if test="${not empty apiMovies}">
                <c:choose>
                    <c:when test="${userRole eq 'ADMIN'}">
                        <div class="register-toolbar">
                            <label><input type="checkbox" data-select-all /> 전체 체크</label>
                            <button type="button" data-register-selected>선택한 영화 등록</button>
                            <button type="button" data-register-all>현재 목록 전체 등록</button>
                            <span class="register-progress" data-register-count>선택된 영화 없음</span>
                            <span class="register-progress" data-register-progress></span>
                        </div>
                        <table class="movie-table">
                            <thead>
                                <tr>
                                    <th>선택</th>
                                    <th>포스터</th>
                                    <th>제목</th>
                                    <th>감독</th>
                                    <th>연도</th>
                                    <th>장르</th>
                                    <th>평점</th>
                                    <th>폭력성</th>
                                    <th>개요</th>
                                    <th>TMDb ID</th>
                                    <th>동작</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="apiMovie" items="${apiMovies}">
                                    <c:set var="alreadyRegistered" value="${not empty apiMovie.id}" />
                                    <tr data-register-row data-api-id="${apiMovie.apiId}" class="${alreadyRegistered ? 'is-registered' : ''}">
                                        <td class="register-check-cell">
                                            <input type="checkbox" class="js-register-check" value="${apiMovie.apiId}" <c:if test="${alreadyRegistered}">disabled</c:if> />
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty apiMovie.posterPath and apiMovie.posterPath ne 'N/A'}">
                                                    <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" class="movie-poster" />
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 포스터" class="movie-poster" />
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="<c:url value='/movies/api-external-detail?imdbId=${apiMovie.apiId}'/>" class="title-link">
                                                ${apiMovie.title}
                                            </a>
                                        </td>
                                        <td>${apiMovie.director}</td>
                                        <td>${apiMovie.year}</td>
                                        <td>${apiMovie.genre}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${apiMovie.rating == 0.0}">
                                                    N/A
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${apiMovie.rating}" pattern="#0.0" />
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${apiMovie.violence_score_avg == 0.0}">
                                                    N/A
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${apiMovie.violence_score_avg}" pattern="#0.0" />
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${fn:substring(apiMovie.overview, 0, 30)}...</td>
                                        <td>${apiMovie.apiId}</td>
                                        <td>
                                            <form action="<c:url value='/movies/import-api-detail'/>" method="post" class="action-form js-register-form" data-api-id="${apiMovie.apiId}">
                                                <input type="hidden" name="imdbId" value="${apiMovie.apiId}" />
                                                <button type="submit" class="action-button js-register-one <c:if test="${alreadyRegistered}">is-complete</c:if>" <c:if test="${alreadyRegistered}">disabled</c:if>>
                                                    <c:choose>
                                                        <c:when test="${alreadyRegistered}">등록 완료</c:when>
                                                        <c:otherwise>이 영화 등록</c:otherwise>
                                                    </c:choose>
                                                </button>
                                                <span class="register-status" data-register-status>
                                                    <c:if test="${alreadyRegistered}">등록 완료</c:if>
                                                </span>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <c:url var="placeholderPosterUrl" value="/resources/images/movies/256px-No-Image-Placeholder.png"/>
                        <c:set var="searchPosterMode" value="${empty posterMode ? 'off' : posterMode}" />
                        <div class="user-search-grid" id="userSearchGrid">
                            <c:forEach var="apiMovie" items="${apiMovies}">
                                <c:url var="detailUrl" value="/movies/api-external-detail">
                                    <c:param name="imdbId" value="${apiMovie.apiId}" />
                                </c:url>
                                <c:set var="normalizedGenre" value="${empty apiMovie.genre ? '' : fn:toLowerCase(apiMovie.genre)}" />
                                <c:set var="normalizedRated" value="${empty apiMovie.rated ? '' : fn:toLowerCase(apiMovie.rated)}" />
                                <c:set var="isHorrorPosterTarget" value="${fn:contains(normalizedGenre, 'horror')
                                    or fn:contains(normalizedGenre, 'thriller')
                                    or fn:contains(apiMovie.genre, '공포')
                                    or fn:contains(apiMovie.genre, '호러')
                                    or fn:contains(apiMovie.genre, '스릴러')}" />
                                <c:set var="isAdultPosterTarget" value="${fn:contains(apiMovie.rated, '청소년')
                                    or fn:contains(apiMovie.rated, '청불')
                                    or fn:contains(normalizedRated, '18')
                                    or fn:contains(normalizedRated, '19')
                                    or normalizedRated eq 'r'
                                    or normalizedRated eq 'nc-17'}" />
                                <%-- 더보기 카드와 기준 맞추기 --%>
                                <c:set var="isPosterProtected" value="${searchPosterMode eq 'all'
                                    or ((searchPosterMode eq 'horror' or searchPosterMode eq 'horror_adult') and isHorrorPosterTarget)
                                    or ((searchPosterMode eq 'adult' or searchPosterMode eq 'horror_adult') and isAdultPosterTarget)}" />
                                <div class="user-search-card" data-detail-url="${detailUrl}" role="link" tabindex="0">
                                    <div class="user-search-poster ${isPosterProtected ? 'is-poster-protected' : ''}"
                                         data-genre="${fn:escapeXml(apiMovie.genre)}"
                                         data-rated="${fn:escapeXml(apiMovie.rated)}">
                                        <c:choose>
                                            <c:when test="${not empty apiMovie.posterPath and apiMovie.posterPath ne 'N/A'}">
                                                <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" />
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${placeholderPosterUrl}" alt="기본 포스터" />
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="poster-privacy-cover">
                                            <span>포스터를 가렸어요</span>
                                            <button type="button" class="poster-privacy-view">보기</button>
                                        </div>
                                        <div class="user-search-overlay">
                                            <c:choose>
                                                <c:when test="${userRole == 'MEMBER'}">
                                                    <button type="button"
                                                            class="poster-action-button search-like-button ${apiMovie.isLiked() ? 'is-liked' : ''}"
                                                            data-api-id="${apiMovie.apiId}"
                                                            aria-label="보고싶어요">
                                                        <i class="bi ${apiMovie.isLiked() ? 'bi-heart-fill' : 'bi-heart'}"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button"
                                                            class="poster-action-button search-login-required"
                                                            aria-label="로그인 후 보고싶어요">
                                                        <i class="bi bi-heart"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                            <a href="${detailUrl}" class="poster-action-button" aria-label="영화 정보 보기">
                                                <i class="bi bi-info-circle"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="user-search-meta">
                                        <div class="user-search-rated" data-api-id="${apiMovie.apiId}">
                                            <c:choose>
                                                <c:when test="${not empty apiMovie.rated and apiMovie.rated ne 'N/A'}">${apiMovie.rated}</c:when>
                                                <c:otherwise>등급 확인 중</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <c:if test="${not empty apiMovie.genre}">
                                            <div class="user-search-genre" title="${apiMovie.genre}">
                                                ${apiMovie.genre}
                                            </div>
                                        </c:if>
                                        <a href="${detailUrl}" class="user-search-title" title="${apiMovie.title}">
                                            ${apiMovie.title}
                                        </a>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <c:if test="${hasMoreSearchResults}">
                            <div class="search-more-wrapper" id="searchMoreWrapper">
                                <button type="button"
                                        class="search-more-button"
                                        id="searchMoreButton"
                                        data-next-page="${nextSearchPage}"
                                        data-next-offset="${nextSearchOffset}">
                                    더보기
                                </button>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </c:if>
    </div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    const searchContextPath = '${pageContext.request.contextPath}';
    const searchPlaceholderPoster = '${placeholderPosterUrl}';
    const searchUserRole = '${userRole}';
    const searchQuery = new URLSearchParams(window.location.search).get('query') || '';
    let searchPosterMode = '${empty posterMode ? "off" : posterMode}';
    const searchGrid = document.getElementById('userSearchGrid');
    const searchMoreWrapper = document.getElementById('searchMoreWrapper');
    const searchMoreButton = document.getElementById('searchMoreButton');

    function openSearchLoginModal() {
        if (window.openPrewatchAuthFrameModal) {
            window.openPrewatchAuthFrameModal({
                url: searchContextPath + '/auth/login',
                title: '로그인'
            });
            return;
        }
        window.location.href = searchContextPath + '/auth/login';
    }

    function escapeSearchHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function getSearchPosterPath(posterPath) {
        if (!posterPath || posterPath === 'N/A') {
            return searchPlaceholderPoster;
        }
        return posterPath;
    }

    function getSearchDetailUrl(apiId) {
        return searchContextPath + '/movies/api-external-detail?imdbId=' + encodeURIComponent(apiId || '');
    }

    function normalizeSearchText(value) {
        return String(value || '').toLowerCase();
    }

    function isHorrorOrThrillerGenre(genre) {
        const normalized = normalizeSearchText(genre);
        return normalized.includes('horror')
            || normalized.includes('thriller')
            || normalized.includes('공포')
            || normalized.includes('호러')
            || normalized.includes('스릴러');
    }

    function isAdultRating(rated) {
        const normalized = normalizeSearchText(rated);
        return normalized.includes('청소년')
            || normalized.includes('청불')
            || normalized.includes('18')
            || normalized.includes('19')
            || normalized === 'r'
            || normalized === 'nc-17';
    }

    function shouldProtectSearchPoster(genre, rated) {
        if (searchPosterMode === 'all') {
            return true;
        }
        if (searchPosterMode === 'horror_adult') {
            return isHorrorOrThrillerGenre(genre) || isAdultRating(rated);
        }
        if (searchPosterMode === 'horror') {
            return isHorrorOrThrillerGenre(genre);
        }
        if (searchPosterMode === 'adult') {
            return isAdultRating(rated);
        }
        return false;
    }

    // 검색창 필터 바꾸면 현재 카드도 다시 계산
    window.addEventListener('prewatch:posterModeChanged', function (event) {
        searchPosterMode = event.detail && event.detail.posterMode ? event.detail.posterMode : 'off';
        applySearchPosterProtection(document);
    });

    // 찜하지 않은 하트만 hover 미리보기
    function setLikeHoverPreview(button, isPreview) {
        if (!button || button.classList.contains('is-liked') || button.disabled) {
            return;
        }

        const icon = button.querySelector('i');
        button.classList.toggle('is-hover-preview', isPreview);
        if (icon) {
            icon.className = 'bi ' + (isPreview ? 'bi-heart-fill' : 'bi-heart');
        }
    }

    // 보기 누른 포스터는 다시 가리지 않음
    function applySearchPosterProtection(root) {
        const scope = root || document;
        Array.from(scope.querySelectorAll('.user-search-poster')).forEach(function (poster) {
            if (poster.classList.contains('is-poster-revealed')) {
                return;
            }
            const shouldProtect = shouldProtectSearchPoster(poster.dataset.genre, poster.dataset.rated);
            poster.classList.toggle('is-poster-protected', shouldProtect);
        });
    }

    function createSearchCard(movie) {
        const apiId = movie && movie.apiId ? movie.apiId : '';
        const title = movie && movie.title ? movie.title : '제목 없음';
        const posterPath = getSearchPosterPath(movie && movie.posterPath);
        const rated = movie && movie.rated && movie.rated !== 'N/A' ? movie.rated : '등급 확인 중';
        const genre = movie && movie.genre ? movie.genre : '';
        const detailUrl = getSearchDetailUrl(apiId);
        const isLiked = !!(movie && movie.liked);
        const protectedClass = shouldProtectSearchPoster(genre, rated) ? ' is-poster-protected' : '';
        const likeButtonHtml = searchUserRole === 'MEMBER'
            ? '<button type="button" class="poster-action-button search-like-button ' + (isLiked ? 'is-liked' : '') + '" data-api-id="' + escapeSearchHtml(apiId) + '" aria-label="보고싶어요"><i class="bi ' + (isLiked ? 'bi-heart-fill' : 'bi-heart') + '"></i></button>'
            : '<button type="button" class="poster-action-button search-login-required" aria-label="로그인 후 보고싶어요"><i class="bi bi-heart"></i></button>';

        return ''
            + '<div class="user-search-card" data-detail-url="' + escapeSearchHtml(detailUrl) + '" role="link" tabindex="0">'
            + '    <div class="user-search-poster' + protectedClass + '" data-genre="' + escapeSearchHtml(genre) + '" data-rated="' + escapeSearchHtml(rated) + '">'
            + '        <img src="' + escapeSearchHtml(posterPath) + '" alt="' + escapeSearchHtml(title) + ' 포스터" />'
            + '        <div class="poster-privacy-cover">'
            + '            <span>포스터를 가렸어요</span>'
            + '            <button type="button" class="poster-privacy-view">보기</button>'
            + '        </div>'
            + '        <div class="user-search-overlay">'
            +              likeButtonHtml
            + '            <a href="' + escapeSearchHtml(detailUrl) + '" class="poster-action-button" aria-label="영화 정보 보기">'
            + '                <i class="bi bi-info-circle"></i>'
            + '            </a>'
            + '        </div>'
            + '    </div>'
            + '    <div class="user-search-meta">'
            + '        <div class="user-search-rated" data-api-id="' + escapeSearchHtml(apiId) + '">' + escapeSearchHtml(rated) + '</div>'
            + (genre ? '        <div class="user-search-genre" title="' + escapeSearchHtml(genre) + '">' + escapeSearchHtml(genre) + '</div>' : '')
            + '        <a href="' + escapeSearchHtml(detailUrl) + '" class="user-search-title" title="' + escapeSearchHtml(title) + '">' + escapeSearchHtml(title) + '</a>'
            + '    </div>'
            + '</div>';
    }

    // 등급은 화면 먼저 띄운 뒤 따로 채움. 끝나면 포스터 가림도 다시 계산.
    function loadSearchCertifications(root) {
        const scope = root || document;
        const ratedElements = Array.from(scope.querySelectorAll('.user-search-rated[data-api-id]'))
            .filter(function (element) {
                return element.dataset.apiId && element.textContent.trim() === '등급 확인 중';
            });

        if (ratedElements.length === 0) {
            return;
        }

        const apiIds = Array.from(new Set(ratedElements.map(function (element) {
            return element.dataset.apiId;
        })));

        fetch(searchContextPath + '/search/certifications?' + new URLSearchParams(apiIds.map(function (apiId) {
            return ['apiIds', apiId];
        })).toString(), {
            headers: { 'Accept': 'application/json' }
        })
        .then(function (response) {
            return response.json().then(function (body) {
                if (!response.ok) {
                    throw body;
                }
                return body;
            });
        })
        .then(function (result) {
            const certifications = result.certifications || {};
            ratedElements.forEach(function (element) {
                const certification = certifications[element.dataset.apiId];
                const ratingText = certification || '등급 미정';
                element.textContent = ratingText;
                const card = element.closest('.user-search-card');
                const poster = card ? card.querySelector('.user-search-poster') : null;
                if (poster) {
                    poster.dataset.rated = ratingText;
                }
            });
            applySearchPosterProtection(scope);
        })
        .catch(function () {
            ratedElements.forEach(function (element) {
                element.textContent = '등급 미정';
                const card = element.closest('.user-search-card');
                const poster = card ? card.querySelector('.user-search-poster') : null;
                if (poster) {
                    poster.dataset.rated = '등급 미정';
                }
            });
            applySearchPosterProtection(scope);
        });
    }

    document.addEventListener('click', function (event) {
        const revealButton = event.target.closest('.poster-privacy-view');
        if (revealButton) {
            event.preventDefault();
            event.stopPropagation();
            const poster = revealButton.closest('.user-search-poster');
            if (poster) {
                poster.classList.remove('is-poster-protected');
                poster.classList.add('is-poster-revealed');
            }
            return;
        }

        const loginButton = event.target.closest('.search-login-required');
        if (loginButton) {
            event.preventDefault();
            openSearchLoginModal();
            return;
        }

        const likeButton = event.target.closest('.search-like-button');
        if (likeButton) {
            event.preventDefault();
            const apiId = likeButton.dataset.apiId;
            if (!apiId || likeButton.disabled) {
                return;
            }

            likeButton.disabled = true;

            fetch(searchContextPath + '/movies/api-toggle-cart', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: new URLSearchParams({ apiId: apiId })
            })
            .then(function (response) {
                return response.json().then(function (body) {
                    if (!response.ok) {
                        throw body;
                    }
                    return body;
                });
            })
            .then(function (result) {
                const isLiked = result.status === 'added';
                const icon = likeButton.querySelector('i');
                likeButton.classList.remove('is-hover-preview');
                likeButton.classList.toggle('is-liked', isLiked);
                if (icon) {
                    icon.className = 'bi ' + (isLiked ? 'bi-heart-fill' : 'bi-heart');
                }
            })
            .catch(function (error) {
                const message = error && error.message ? error.message : '찜 처리 중 오류가 발생했습니다.';
                alert(message);
            })
            .finally(function () {
                likeButton.disabled = false;
            });
            return;
        }

        const card = event.target.closest('.user-search-card[data-detail-url]');
        if (!card || event.target.closest('a, button')) {
            return;
        }

        window.location.href = card.dataset.detailUrl;
    });

    document.addEventListener('pointerover', function (event) {
        const likeButton = event.target.closest('.search-like-button');
        if (!likeButton || likeButton.contains(event.relatedTarget)) {
            return;
        }
        setLikeHoverPreview(likeButton, true);
    });

    document.addEventListener('pointerout', function (event) {
        const likeButton = event.target.closest('.search-like-button');
        if (!likeButton || likeButton.contains(event.relatedTarget)) {
            return;
        }
        setLikeHoverPreview(likeButton, false);
    });

    document.addEventListener('keydown', function (event) {
        if (event.key !== 'Enter' && event.key !== ' ') {
            return;
        }

        const card = event.target.closest('.user-search-card[data-detail-url]');
        if (!card || event.target.closest('a, button')) {
            return;
        }

        event.preventDefault();
        window.location.href = card.dataset.detailUrl;
    });

    if (searchMoreButton && searchGrid) {
        searchMoreButton.addEventListener('click', function () {
            if (searchMoreButton.disabled) {
                return;
            }

            const nextPage = searchMoreButton.dataset.nextPage || '1';
            const nextOffset = searchMoreButton.dataset.nextOffset || '0';
            searchMoreButton.disabled = true;
            searchMoreButton.textContent = '불러오는 중';

            fetch(searchContextPath + '/search/more?' + new URLSearchParams({
                query: searchQuery,
                page: nextPage,
                offset: nextOffset
            }).toString(), {
                headers: { 'Accept': 'application/json' }
            })
            .then(function (response) {
                return response.json().then(function (body) {
                    if (!response.ok) {
                        throw body;
                    }
                    return body;
                });
            })
            .then(function (result) {
                const movies = result.movies || [];
                const fragment = document.createDocumentFragment();
                movies.forEach(function (movie) {
                    const template = document.createElement('template');
                    template.innerHTML = createSearchCard(movie).trim();
                    fragment.appendChild(template.content.firstElementChild);
                });
                searchGrid.appendChild(fragment);
                loadSearchCertifications(searchGrid);
                applySearchPosterProtection(searchGrid);

                if (result.hasMore) {
                    searchMoreButton.dataset.nextPage = result.nextPage;
                    searchMoreButton.dataset.nextOffset = result.nextOffset;
                    searchMoreButton.disabled = false;
                    searchMoreButton.textContent = '더보기';
                } else if (searchMoreWrapper) {
                    searchMoreWrapper.style.display = 'none';
                }
            })
            .catch(function (error) {
                const message = error && error.message ? error.message : '검색 결과를 더 불러오지 못했습니다.';
                alert(message);
                searchMoreButton.disabled = false;
                searchMoreButton.textContent = '더보기';
            });
        });
    }

    applySearchPosterProtection(document);
    loadSearchCertifications(document);
    </script>
    <div class="import-toast" data-register-toast></div>
    <script src="<c:url value='/resources/js/movie-import-register.js'/>"></script>
</body>
</html>
