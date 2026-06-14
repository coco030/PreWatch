<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>개봉예정영화 관리</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>?v=home-overview-20260611">
    <style>
        body {
            margin: 0;
            background: #f4f4f4;
            color: #333;
            font-family: Arial, sans-serif;
        }

        .container {
            width: 90%;
            max-width: 1320px;
            margin: 20px auto;
            padding: 24px;
            background: #fff;
            border: 1px solid #e7ecf3;
            border-radius: 10px;
            box-shadow: 0 12px 34px rgba(15, 23, 42, 0.08);
        }

        .page-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            border-bottom: 1px solid #d8dee8;
            padding-bottom: 16px;
            margin-bottom: 18px;
        }

        h2 {
            margin: 0;
            color: #1f2937;
            font-size: 2rem;
            font-weight: 850;
        }

        .back-button,
        .page-button {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 4px;
            background: #6c757d;
            color: #fff;
            text-decoration: none;
        }

        .page-button {
            background: #fff;
            color: #333;
            border: 1px solid #6c757d;
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

        .manage-section {
            margin-bottom: 28px;
            padding-bottom: 22px;
            border-bottom: 1px solid #d8dee8;
        }

        .register-section {
            padding-top: 4px;
        }

        .section-title-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
        }

        .section-title-row h3 {
            margin: 0;
            color: #1f2937;
            font-size: 1.25rem;
        }

        .section-count {
            color: #6b7280;
            font-weight: 700;
        }

        .manage-table-wrap {
            border: 1px solid #ddd;
            border-radius: 6px;
            background: #fff;
        }

        .manage-table {
            width: 100%;
            min-width: 0;
            table-layout: fixed;
            border-collapse: collapse;
        }

        .manage-table th,
        .manage-table td {
            border-bottom: 1px solid #e5e7eb;
            padding: 10px 12px;
            text-align: left;
            vertical-align: middle;
        }

        .manage-table th {
            background: #f3f4f6;
            color: #374151;
        }

        .manage-table tr:last-child td {
            border-bottom: 0;
        }

        .manage-title {
            color: #1f2937;
            font-weight: 800;
            text-decoration: none;
        }

        .manage-title:hover {
            text-decoration: underline;
        }

        .manage-actions {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .manage-actions form {
            margin: 0;
        }

        .manage-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 32px;
            padding: 0 10px;
            border: 1px solid #6c757d;
            border-radius: 4px;
            background: #fff;
            color: #333;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }

        .manage-button.delete {
            border-color: #dc3545;
            color: #dc3545;
        }

        .manage-check-cell {
            width: 48px;
            text-align: center;
        }

        .manage-poster-cell {
            width: 96px;
        }

        .manage-date-cell,
        .manage-rated-cell {
            width: 120px;
        }

        .manage-action-cell {
            width: 180px;
        }

        .manage-page-form,
        .manage-bulk-form {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin: 0;
        }

        .manage-page-input {
            width: 82px;
        }

        .manage-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin: 12px 0;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 6px;
            background: #fafafa;
        }

        .selected-count-text {
            color: #6c757d;
            font-weight: 700;
        }

        .manage-pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 14px;
        }

        .manage-pagination a,
        .manage-pagination span {
            min-width: 34px;
            padding: 6px 10px;
            border: 1px solid #d1d5db;
            border-radius: 4px;
            color: #374151;
            text-align: center;
            text-decoration: none;
            background: #fff;
        }

        .manage-pagination .active-page {
            border-color: #6c63d9;
            background: #6c63d9;
            color: #fff;
            font-weight: 800;
        }

        .manage-pagination .disabled-page {
            color: #9ca3af;
            background: #f3f4f6;
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

        .candidate-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
        }

        .candidate-table th,
        .candidate-table td {
            border: 1px solid #ddd;
            padding: 12px;
            vertical-align: middle;
            text-align: left;
        }

        .candidate-table th {
            background: #333;
            color: #fff;
        }

        .candidate-table tbody tr:nth-child(even) {
            background: #f9f9f9;
        }

        .register-check-cell {
            width: 56px;
            text-align: center;
        }

        .movie-poster {
            width: 82px;
            height: 122px;
            object-fit: cover;
            border-radius: 4px;
            display: block;
        }

        .title-link {
            color: #007bff;
            font-weight: bold;
            text-decoration: none;
        }

        .title-link:hover {
            text-decoration: underline;
        }

        .overview {
            max-width: 520px;
            color: #555;
            line-height: 1.5;
        }

        .action-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
        }

        .action-button.is-complete {
            background-color: #6c757d;
            cursor: default;
        }

        .register-status {
            display: block;
            margin-top: 6px;
            color: #6c757d;
            font-size: 13px;
        }

        .register-progress {
            color: #666;
            font-size: 14px;
        }

        .pager {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 18px;
            flex-wrap: wrap;
        }

        .no-results {
            margin: 40px 0;
            text-align: center;
            color: #777;
        }

        @media (max-width: 900px) {
            .manage-poster-cell {
                display: none;
            }
            .manage-action-cell {
                width: 150px;
            }
            .manage-date-cell,
            .manage-rated-cell {
                width: 96px;
            }
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
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <main class="container" data-register-panel data-import-url="<c:url value='/movies/import-api-detail/ajax'/>">
        <div class="page-head">
            <h2>개봉예정영화 관리</h2>
            <div>
                <a href="<c:url value='/movies'/>" class="back-button">내 영화 관리페이지로 돌아가기</a>
            </div>
        </div>

        <c:if test="${not empty param.status && param.status == 'deleted'}">
            <div class="register-toolbar">
                선택한 개봉예정영화가 삭제되었습니다.
            </div>
        </c:if>
        <c:if test="${not empty param.status && param.status == 'updated'}">
            <div class="register-toolbar">
                개봉예정영화 정보가 수정되었습니다.
            </div>
        </c:if>
        <c:if test="${not empty param.error && param.error == 'noSelection'}">
            <div class="register-toolbar">
                삭제할 개봉예정영화를 선택해주세요.
            </div>
        </c:if>

        <section class="manage-section">
            <div class="section-title-row">
                <h3>개봉예정영화 관리</h3>
                <span class="section-count">총 ${managedTotalMovies}개</span>
            </div>
            <div class="manage-toolbar">
                <form class="manage-bulk-form" id="selectedUpcomingDeleteForm" action="<c:url value='/movies/delete-selected'/>" method="post"
                      onsubmit="return confirm('선택한 개봉예정영화를 삭제하시겠습니까?');">
                    <input type="hidden" name="returnTo" value="upcoming" />
                    <input type="hidden" name="managedPage" value="${managedCurrentPage}" />
                    <input type="hidden" name="managedSize" value="${managedPageSize}" />
                    <label><input type="checkbox" id="selectAllUpcomingMovies" /> 전체 체크</label>
                    <button type="submit" class="manage-button delete">선택 삭제</button>
                    <span id="selectedUpcomingMovieCount" class="selected-count-text">선택된 영화 0개</span>
                </form>
                <form class="manage-page-form" action="<c:url value='/movies/upcoming-candidates'/>" method="get">
                    <input type="hidden" name="page" value="${currentPage}" />
                    <input type="hidden" name="managedPage" value="1" />
                    <label for="managedPageSize">표시 개수</label>
                    <input id="managedPageSize" name="managedSize" type="number" min="1" max="50"
                           class="manage-page-input" value="${managedPageSize}" />
                    <button type="submit" class="manage-button">보기</button>
                </form>
            </div>
            <c:choose>
                <c:when test="${not empty managedUpcomingMovies}">
                    <div class="manage-table-wrap">
                        <table class="manage-table">
                            <thead>
                                <tr>
                                    <th class="manage-check-cell">선택</th>
                                    <th class="manage-poster-cell">포스터</th>
                                    <th>제목</th>
                                    <th class="manage-date-cell">개봉일</th>
                                    <th class="manage-rated-cell">등급</th>
                                    <th class="manage-action-cell">관리</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="movie" items="${managedUpcomingMovies}">
                                    <tr>
                                        <td class="manage-check-cell">
                                            <input type="checkbox" class="js-upcoming-manage-check" name="movieIds" value="${movie.id}" form="selectedUpcomingDeleteForm" />
                                        </td>
                                        <td class="manage-poster-cell">
                                            <c:choose>
                                                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                                    <img src="${movie.posterPath}" alt="${movie.title} 포스터" class="movie-poster" />
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 포스터" class="movie-poster" />
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="<c:url value='/movies/${movie.id}'/>" class="manage-title">${movie.title}</a>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty movie.formattedReleaseDate}">${movie.formattedReleaseDate}</c:when>
                                                <c:otherwise>미정</c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty movie.dday}">
                                                <span class="register-status">D-${movie.dday}</span>
                                            </c:if>
                                        </td>
                                        <td class="manage-rated-cell">
                                            <c:choose>
                                                <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                                                <c:otherwise>등급 미정</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="manage-action-cell">
                                            <div class="manage-actions">
                                                <c:url var="upcomingEditUrl" value="/movies/${movie.id}/edit">
                                                    <c:param name="returnTo" value="upcoming" />
                                                    <c:param name="managedPage" value="${managedCurrentPage}" />
                                                    <c:param name="managedSize" value="${managedPageSize}" />
                                                </c:url>
                                                <a href="${upcomingEditUrl}" class="manage-button">수정</a>
                                                <a href="<c:url value='/movies/${movie.id}'/>" class="manage-button">상세</a>
                                                <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" onsubmit="return confirm('이 개봉예정영화를 삭제하시겠습니까?');">
                                                    <input type="hidden" name="returnTo" value="upcoming" />
                                                    <input type="hidden" name="managedPage" value="${managedCurrentPage}" />
                                                    <input type="hidden" name="managedSize" value="${managedPageSize}" />
                                                    <button type="submit" class="manage-button delete">삭제</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="manage-pagination">
                        <c:choose>
                            <c:when test="${managedCurrentPage > 1}">
                                <c:url var="managedFirstUrl" value="/movies/upcoming-candidates">
                                    <c:param name="page" value="${currentPage}" />
                                    <c:param name="managedPage" value="1" />
                                    <c:param name="managedSize" value="${managedPageSize}" />
                                </c:url>
                                <c:url var="managedPrevUrl" value="/movies/upcoming-candidates">
                                    <c:param name="page" value="${currentPage}" />
                                    <c:param name="managedPage" value="${managedCurrentPage - 1}" />
                                    <c:param name="managedSize" value="${managedPageSize}" />
                                </c:url>
                                <a href="${managedFirstUrl}">처음</a>
                                <a href="${managedPrevUrl}">이전</a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled-page">처음</span>
                                <span class="disabled-page">이전</span>
                            </c:otherwise>
                        </c:choose>

                        <c:forEach var="managedPageNumber" begin="${managedStartPage}" end="${managedEndPage}">
                            <c:choose>
                                <c:when test="${managedPageNumber == managedCurrentPage}">
                                    <span class="active-page">${managedPageNumber}</span>
                                </c:when>
                                <c:otherwise>
                                    <c:url var="managedPageUrl" value="/movies/upcoming-candidates">
                                        <c:param name="page" value="${currentPage}" />
                                        <c:param name="managedPage" value="${managedPageNumber}" />
                                        <c:param name="managedSize" value="${managedPageSize}" />
                                    </c:url>
                                    <a href="${managedPageUrl}">${managedPageNumber}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:choose>
                            <c:when test="${managedCurrentPage < managedTotalPages}">
                                <c:url var="managedNextUrl" value="/movies/upcoming-candidates">
                                    <c:param name="page" value="${currentPage}" />
                                    <c:param name="managedPage" value="${managedCurrentPage + 1}" />
                                    <c:param name="managedSize" value="${managedPageSize}" />
                                </c:url>
                                <c:url var="managedLastUrl" value="/movies/upcoming-candidates">
                                    <c:param name="page" value="${currentPage}" />
                                    <c:param name="managedPage" value="${managedTotalPages}" />
                                    <c:param name="managedSize" value="${managedPageSize}" />
                                </c:url>
                                <a href="${managedNextUrl}">다음</a>
                                <a href="${managedLastUrl}">마지막</a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled-page">다음</span>
                                <span class="disabled-page">마지막</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="no-results">관리 중인 개봉예정영화가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </section>

        <section class="register-section" id="upcoming-register">
            <c:url var="candidatePrevUrl" value="/movies/upcoming-candidates">
                <c:param name="page" value="${prevPage}" />
                <c:param name="managedPage" value="${managedCurrentPage}" />
                <c:param name="managedSize" value="${managedPageSize}" />
            </c:url>
            <c:url var="candidateNextUrl" value="/movies/upcoming-candidates">
                <c:param name="page" value="${nextPage}" />
                <c:param name="managedPage" value="${managedCurrentPage}" />
                <c:param name="managedSize" value="${managedPageSize}" />
            </c:url>
            <div class="section-title-row">
                <h3>새 개봉예정영화 등록</h3>
                <span class="section-count">후보 ${fn:length(upcomingCandidates)}개</span>
            </div>
            <div class="pager">
                <a class="page-button" href="${candidatePrevUrl}#upcoming-register">이전 후보</a>
                <span class="page-button">${currentPage}페이지</span>
                <a class="page-button" href="${candidateNextUrl}#upcoming-register">다음 후보 불러오기</a>
            </div>
            <div class="register-toolbar">
                <label><input type="checkbox" data-select-all /> 전체 체크</label>
                <button type="button" data-register-selected>선택한 영화 등록</button>
                <button type="button" data-register-all>현재 목록 전체 등록</button>
                <span class="register-progress" data-register-count>선택된 영화 없음</span>
                <span class="register-progress" data-register-progress></span>
            </div>

            <c:choose>
            <c:when test="${not empty upcomingCandidates}">
                <table class="candidate-table">
                    <thead>
                        <tr>
                            <th>선택</th>
                            <th>포스터</th>
                            <th>제목</th>
                            <th>개봉일</th>
                            <th>개요</th>
                            <th>TMDb ID</th>
                            <th>동작</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="movie" items="${upcomingCandidates}">
                            <c:set var="alreadyRegistered" value="${not empty movie.id}" />
                            <tr data-register-row data-api-id="${movie.apiId}" class="${alreadyRegistered ? 'is-registered' : ''}">
                                <td class="register-check-cell">
                                    <input type="checkbox" class="js-register-check" value="${movie.apiId}" <c:if test="${alreadyRegistered}">disabled</c:if> />
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                            <img src="${movie.posterPath}" alt="${movie.title} 포스터" class="movie-poster" />
                                        </c:when>
                                        <c:otherwise>
                                            <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 포스터" class="movie-poster" />
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${alreadyRegistered}">
                                            <a href="<c:url value='/movies/${movie.id}'/>" class="title-link">${movie.title}</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="<c:url value='/movies/api-external-detail?imdbId=${movie.apiId}'/>" class="title-link">${movie.title}</a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty movie.formattedReleaseDate}">${movie.formattedReleaseDate}</c:when>
                                        <c:otherwise>미정</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="overview">${fn:substring(movie.overview, 0, 80)}<c:if test="${fn:length(movie.overview) > 80}">...</c:if></td>
                                <td>${movie.apiId}</td>
                                <td>
                                    <form action="<c:url value='/movies/import-api-detail'/>" method="post" class="js-register-form" data-api-id="${movie.apiId}">
                                        <input type="hidden" name="imdbId" value="${movie.apiId}" />
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
                <p class="no-results">불러온 개봉예정영화가 없습니다.</p>
            </c:otherwise>
            </c:choose>

            <div class="pager">
                <a class="page-button" href="${candidatePrevUrl}#upcoming-register">이전 후보</a>
                <span class="page-button">${currentPage}페이지</span>
                <a class="page-button" href="${candidateNextUrl}#upcoming-register">다음 후보 불러오기</a>
            </div>
        </section>
    </main>

    <div class="import-toast" data-register-toast></div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="<c:url value='/resources/js/movie-import-register.js'/>"></script>
    <script>
        const selectAllUpcomingMovies = document.getElementById('selectAllUpcomingMovies');
        const upcomingManageChecks = Array.from(document.querySelectorAll('.js-upcoming-manage-check'));
        const selectedUpcomingMovieCount = document.getElementById('selectedUpcomingMovieCount');

        function updateUpcomingManageCount() {
            const checkedCount = upcomingManageChecks.filter(function (checkbox) {
                return checkbox.checked;
            }).length;

            if (selectedUpcomingMovieCount) {
                selectedUpcomingMovieCount.textContent = '선택된 영화 ' + checkedCount + '개';
            }

            if (selectAllUpcomingMovies) {
                selectAllUpcomingMovies.checked = checkedCount > 0 && checkedCount === upcomingManageChecks.length;
                selectAllUpcomingMovies.indeterminate = checkedCount > 0 && checkedCount < upcomingManageChecks.length;
            }
        }

        if (selectAllUpcomingMovies) {
            selectAllUpcomingMovies.addEventListener('change', function () {
                upcomingManageChecks.forEach(function (checkbox) {
                    checkbox.checked = selectAllUpcomingMovies.checked;
                });
                updateUpcomingManageCount();
            });
        }

        upcomingManageChecks.forEach(function (checkbox) {
            checkbox.addEventListener('change', updateUpcomingManageCount);
        });

        updateUpcomingManageCount();
    </script>
</body>
</html>
