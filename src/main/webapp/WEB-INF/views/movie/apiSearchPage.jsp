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
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
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
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        h2 {
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 20px;
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

        .user-search-overlay {
            position: absolute;
            inset: 0;
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

            .user-search-meta {
                font-size: 0.78rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="container">
        <c:if test="${userRole == 'ADMIN'}">
            <p class="back-link"><a href="<c:url value='/movies'/>" class="back-button">내 영화 관리페이지로 돌아가기</a></p>
        </c:if> 
        <hr>

        <c:if test="${searchPerformed}">
            <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
                <p class="error-message">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
            </c:if>

            <h2>"${query}" 검색 결과</h2>
            <c:if test="${empty apiMovies}">
                <p class="no-results">검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
            </c:if>

            <c:if test="${not empty apiMovies}">
                <c:choose>
                    <c:when test="${userRole == 'ADMIN'}">
                        <table class="movie-table">
                            <thead>
                                <tr>
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
                                    <tr>
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
                                            <form action="<c:url value='/movies/import-api-detail'/>" method="post" class="action-form">
                                                <input type="hidden" name="imdbId" value="${apiMovie.apiId}" />
                                                <button type="submit" class="action-button">이 영화 등록</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <c:url var="placeholderPosterUrl" value="/resources/images/movies/256px-No-Image-Placeholder.png"/>
                        <div class="user-search-grid" id="userSearchGrid">
                            <c:forEach var="apiMovie" items="${apiMovies}">
                                <c:url var="detailUrl" value="/movies/api-external-detail">
                                    <c:param name="imdbId" value="${apiMovie.apiId}" />
                                </c:url>
                                <div class="user-search-card" data-detail-url="${detailUrl}" role="link" tabindex="0">
                                    <div class="user-search-poster">
                                        <c:choose>
                                            <c:when test="${not empty apiMovie.posterPath and apiMovie.posterPath ne 'N/A'}">
                                                <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" />
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${placeholderPosterUrl}" alt="기본 포스터" />
                                            </c:otherwise>
                                        </c:choose>
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

    function createSearchCard(movie) {
        const apiId = movie && movie.apiId ? movie.apiId : '';
        const title = movie && movie.title ? movie.title : '제목 없음';
        const posterPath = getSearchPosterPath(movie && movie.posterPath);
        const rated = movie && movie.rated && movie.rated !== 'N/A' ? movie.rated : '등급 확인 중';
        const genre = movie && movie.genre ? movie.genre : '';
        const detailUrl = getSearchDetailUrl(apiId);
        const isLiked = !!(movie && movie.liked);
        const likeButtonHtml = searchUserRole === 'MEMBER'
            ? '<button type="button" class="poster-action-button search-like-button ' + (isLiked ? 'is-liked' : '') + '" data-api-id="' + escapeSearchHtml(apiId) + '" aria-label="보고싶어요"><i class="bi ' + (isLiked ? 'bi-heart-fill' : 'bi-heart') + '"></i></button>'
            : '<button type="button" class="poster-action-button search-login-required" aria-label="로그인 후 보고싶어요"><i class="bi bi-heart"></i></button>';

        return ''
            + '<div class="user-search-card" data-detail-url="' + escapeSearchHtml(detailUrl) + '" role="link" tabindex="0">'
            + '    <div class="user-search-poster">'
            + '        <img src="' + escapeSearchHtml(posterPath) + '" alt="' + escapeSearchHtml(title) + ' 포스터" />'
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
                element.textContent = certification || '등급 미정';
            });
        })
        .catch(function () {
            ratedElements.forEach(function (element) {
                element.textContent = '등급 미정';
            });
        });
    }

    document.addEventListener('click', function (event) {
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

    loadSearchCertifications(document);
    </script>
</body>
</html>
