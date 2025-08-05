<%-- /WEB-INF/views/movie/allRecentCommentList.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>모든 최근 댓글</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <link rel="stylesheet" href="<c:url value='/resources/css/comment-card.css'/>">
</head>

<body class="bg-light">
    <div class="container py-4">
        <h2 class="section-title text-center mb-4">모든 최근 댓글</h2>

        <div class="row mb-4 justify-content-between">
            <div class="col-md-6 col-lg-4 d-flex">
                <form id="search-form" action="<c:url value='/movies/all-recent-comments'/>" method="get" class="d-flex flex-grow-1">
                    <input type="hidden" name="page" value="1">
                    <input type="hidden" name="limit" value="${limit}">
                    <input type="hidden" name="sortBy" value="${sortBy}">
                    <input type="hidden" name="sortDirection" value="${sortDirection}">
                    <div class="input-group">
                        <select name="searchType" class="form-select" style="max-width: 120px;">
                            <option value="all" <c:if test="${searchType eq 'all'}">selected</c:if>>전체</option>
                            <option value="content" <c:if test="${searchType eq 'content'}">selected</c:if>>내용</option>
                            <option value="title" <c:if test="${searchType eq 'title'}">selected</c:if>>제목</option>
                            <option value="writer" <c:if test="${searchType eq 'writer'}">selected</c:if>>글쓴이</option>
                        </select>
                        <input type="text" name="keyword" class="form-control" placeholder="검색어를 입력하세요" value="${keyword}">
                        <button class="btn btn-primary" type="submit">검색</button>
                    </div>
                </form>
            </div>
            <div class="col-md-6 col-lg-4 mt-3 mt-md-0 d-flex justify-content-end">
                <div class="dropdown">
                    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false">
                        정렬 기준:
                        <c:choose>
                            <c:when test="${sortBy eq 'date'}">최신순</c:when>
                            <c:when test="${sortBy eq 'rating'}">별점순</c:when>
                            <c:when test="${sortBy eq 'like'}">찜순</c:when>
                            <c:otherwise>최신순</c:otherwise>
                        </c:choose>
                        (<c:if test="${sortDirection eq 'desc'}">내림차순</c:if><c:if test="${sortDirection eq 'asc'}">오름차순</c:if>)
                    </button>
                    <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                        <li><a class="dropdown-item" href="<c:url value='/movies/all-recent-comments?page=${currentPage}&limit=${limit}&sortBy=date&sortDirection=desc&searchType=${searchType}&keyword=${keyword}'/>">최신순 (내림차순)</a></li>
                        <li><a class="dropdown-item" href="<c:url value='/movies/all-recent-comments?page=${currentPage}&limit=${limit}&sortBy=rating&sortDirection=desc&searchType=${searchType}&keyword=${keyword}'/>">별점순 (높은순)</a></li>
                        <li><a class="dropdown-item" href="<c:url value='/movies/all-recent-comments?page=${currentPage}&limit=${limit}&sortBy=rating&sortDirection=asc&searchType=${searchType}&keyword=${keyword}'/>">별점순 (낮은순)</a></li>
                        <li><a class="dropdown-item" href="<c:url value='/movies/all-recent-comments?page=${currentPage}&limit=${limit}&sortBy=like&sortDirection=desc&searchType=${searchType}&keyword=${keyword}'/>">찜순 (높은순)</a></li>
                        <li><a class="dropdown-item" href="<c:url value='/movies/all-recent-comments?page=${currentPage}&limit=${limit}&sortBy=like&sortDirection=asc&searchType=${searchType}&keyword=${keyword}'/>">찜순 (낮은순)</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="row g-3 justify-content-center">
            <c:choose>
                <c:when test="${not empty recentComments}">
                    <c:forEach var="review" items="${recentComments}">
                        <div class="col-12 col-md-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/movies/${review.movieId}" class="text-decoration-none text-dark">
                                <div class="card h-100 shadow-sm border-0 p-3 d-flex flex-column comment-card">
                                    <div class="d-flex align-items-center justify-content-between mb-2">
                                        <div class="d-flex align-items-center">
                                            <span class="fw-semibold text-dark me-2">${review.memberId}</span>
                                            <span class="d-flex align-items-center small">
                                                <c:set var="userRating5Point" value="${review.userRating / 2.0}" />
                                                <c:set var="fullStars" value="${fn:split(userRating5Point, '.')[0]}" />
                                                <c:set var="hasHalfStar" value="${fn:length(fn:split(userRating5Point, '.')) > 1 and fn:split(userRating5Point, '.')[1] eq '5'}" />
                                                <c:forEach begin="1" end="${fullStars}">
                                                    <i class="fas fa-star text-warning me-1"></i>
                                                </c:forEach>
                                                <c:if test="${hasHalfStar}">
                                                    <i class="fas fa-star-half-alt text-warning me-1"></i>
                                                </c:if>
                                                <c:forEach begin="1" end="${5 - fullStars - (hasHalfStar ? 1 : 0)}">
                                                    <i class="far fa-star text-muted me-1"></i>
                                                </c:forEach>
                                                <span class="text-muted ms-1">(<fmt:formatNumber value="${userRating5Point}" pattern="#0.0" /> / 5.0)</span>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="d-flex mb-3 flex-grow-1">
                                        <img
                                            src="${review.posterPath != null && review.posterPath != '' ? review.posterPath : pageContext.request.contextPath.concat('/resources/images/movies/256px-No-Image-Placeholder.png')}"
                                            onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png';"
                                            alt="${review.movieName} 포스터"
                                            class="rounded me-3"
                                            style="width: 60px; height: 90px; object-fit: cover; flex-shrink: 0;"
                                        />
                                        <div class="flex-grow-1">
                                            <h5 class="fw-semibold text-dark mb-1">${review.movieName}</h5>
                                            <p class="text-muted small" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis;">
                                                ${review.reviewContent}
                                            </p>
                                        </div>
                                    </div>
                                    <div class="d-flex align-items-center mt-auto pt-2 border-top">
                                        <i class="fas fa-heart text-danger me-2"></i>
                                        <span class="small text-muted">찜 ${review.newLikeCount}</span>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="col-12">
                        <p class="text-center text-muted">검색 결과가 없습니다.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-center">
                <c:set var="startPage" value="${currentPage - (currentPage - 1) % 5}" />
                <c:set var="endPage" value="${startPage + 4 > totalPages ? totalPages : startPage + 4}" />

                <li class="page-item <c:if test="${currentPage eq 1}">disabled</c:if>">
                    <a class="page-link" href="<c:url value='/movies/all-recent-comments?page=1&limit=${limit}&sortBy=${sortBy}&sortDirection=${sortDirection}&searchType=${searchType}&keyword=${keyword}'/>">처음</a>
                </li>
                <li class="page-item <c:if test="${currentPage le 1}">disabled</c:if>">
                    <a class="page-link" href="<c:url value='/movies/all-recent-comments?page=${currentPage - 1}&limit=${limit}&sortBy=${sortBy}&sortDirection=${sortDirection}&searchType=${searchType}&keyword=${keyword}'/>">이전</a>
                </li>

                <c:forEach begin="${startPage}" end="${endPage}" var="pageNumber">
                    <li class="page-item <c:if test="${pageNumber eq currentPage}">active</c:if>">
                        <a class="page-link" href="<c:url value='/movies/all-recent-comments?page=${pageNumber}&limit=${limit}&sortBy=${sortBy}&sortDirection=${sortDirection}&searchType=${searchType}&keyword=${keyword}'/>">${pageNumber}</a>
                    </li>
                </c:forEach>

                <li class="page-item <c:if test="${currentPage ge totalPages}">disabled</c:if>">
                    <a class="page-link" href="<c:url value='/movies/all-recent-comments?page=${currentPage + 1}&limit=${limit}&sortBy=${sortBy}&sortDirection=${sortDirection}&searchType=${searchType}&keyword=${keyword}'/>">다음</a>
                </li>
                <li class="page-item <c:if test="${currentPage eq totalPages}">disabled</c:if>">
                    <a class="page-link" href="<c:url value='/movies/all-recent-comments?page=${totalPages}&limit=${limit}&sortBy=${sortBy}&sortDirection=${sortDirection}&searchType=${searchType}&keyword=${keyword}'/>">마지막</a>
                </li>
            </ul>
        </nav>

    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>