<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%System.out.println("영화 상세페이지 진입"); %>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: ${movie.title} 상세 정보</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
   
    .hero-section {
        position: relative;
        padding: 4rem 0;
        background-size: cover;
        background-position: center;
        color: white;
    }
    .hero-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(to right, rgba(0,0,0,0.9) 20%, rgba(0,0,0,0.6) 50%, rgba(0,0,0,0.2) 100%);
    }
    .hero-content {
        position: relative;
        z-index: 2;
    }
    .hero-section .display-5 {
        font-weight: 600;
    }
    .hero-section .text-meta {
        font-size: 1.1rem;
        color: #e0e0e0;
    }
    .hero-section .poster-img {
        width: 100%;
        max-width: 250px;
        border-radius: 8px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.4);
    }
    
    /* 찜하기 버튼 (어두운 배경용) */
    .like-component {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 8px 16px; border: 1px solid rgba(255,255,255,0.5);
        border-radius: 50px; transition: all 0.2s ease-in-out; user-select: none;
        background-color: rgba(255,255,255,0.1);
    }
    .like-component:hover {
        background-color: rgba(255,255,255,0.2);
        border-color: rgba(255,255,255,0.8);
    }
    .like-component.active { cursor: pointer; }
    .like-component.login-required { cursor: pointer; }
    .like-component.disabled { cursor: not-allowed; background-color: rgba(0,0,0,0.3); color: #ccc; border-color: transparent; }
    .like-component .like-icon.fas { color: #dc3545; }
    .like-component .like-icon.far { color: #f8f9fa; }
    .like-component .like-count { font-size: 0.95em; font-weight: 500; color: #f8f9fa; }

    /* 주의 요소 */
    .warning-section-compact {
        padding: 8px; border-radius: 8px; background-color: transparent;
        cursor: pointer; transition: background-color 0.2s ease;
    }
    .warning-section-compact:hover { background-color: #f8f9fa; }
    .icon-group { display: inline-flex; gap: 8px; }
    .icon-group img { width: 28px; height: 28px; }
    .details-content { display: none; margin-top: 15px; padding: 20px; background-color: #fff; border: 1px solid #e9ecef; border-radius: 8px; }
    .warning-list-flat { padding-left: 20px; list-style-type: '✓ '; margin: 0; }
    .warning-list-flat li { margin-bottom: 5px; }

    /* 점수 입력 패널 */
    .score-input-panel .score-row { display: flex; align-items: center; padding: 4px 0; border-bottom: 1px solid #f1f1f1; }
    .score-input-panel .score-row:last-child { border-bottom: none; }
    .score-input-panel .label { flex-shrink: 0; width: 70px; font-weight: 500; font-size: 0.95rem; margin-right: 1rem; }
    .score-input-panel .avg-score { flex-shrink: 0; width: 70px; font-size: 0.9rem; color: #6c757d; }
    .border-end-lg { border-right: 1px solid #dee2e6 !important; }
    
    /* 메인 컨텐츠 2단 레이아웃 */
    .main-content-col { padding-right: 2rem; }
    .sidebar-col { padding-left: 2rem; }
    @media (max-width: 991.98px) {
        .border-end-lg { border-right: none !important; border-bottom: 1px solid #dee2e6; padding-bottom: 1.5rem; margin-bottom: 1.5rem; }
        .main-content-col { padding-right: 0; }
        .sidebar-col { padding-left: 0; border-top: 1px solid #dee2e6; margin-top: 2rem; padding-top: 2rem; }
    }
</style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<c:set var="backdropUrl" value="https://image.tmdb.org/t/p/original${backdropPath}" />

<div class="hero-section" 
     style="<c:if test='${not empty backdropPath and backdropPath ne "null"}'>background-image: url('${backdropUrl}');</c:if>
            <c:if test='${empty backdropPath or backdropPath eq "null"}'>background: linear-gradient(45deg, #2c3e50, #3498db);</c:if>">
    <div class="hero-overlay"></div>
    <div class="container hero-content">
        <div class="row align-items-center">
            
            <%-- Hero - 포스터 --%>
            <div class="col-md-4 col-lg-3 text-center text-md-start">
                 <c:choose>
                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                        <c:set var="posterSrc"><c:choose><c:when test="${fn:startsWith(movie.posterPath, 'http')}">${movie.posterPath}</c:when><c:otherwise>${pageContext.request.contextPath}${movie.posterPath}</c:otherwise></c:choose></c:set>
                        <img src="${posterSrc}" alt="${movie.title} 포스터" class="poster-img" />
                    </c:when>
                    <c:otherwise><img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" class="poster-img" /></c:otherwise>
                </c:choose>
            </div>
            
          <div class="col-md-8 col-lg-9 mt-4 mt-md-0">
                <h1 class="display-5">${movie.title}</h1>
                <p class="text-meta">
                    ${movie.director} 감독
                    <c:if test="${not empty movie.releaseDate and movie.releaseDate ne 'N/A'}">・ ${movie.releaseDate} 개봉</c:if>
                    <c:if test="${not empty movie.genre and movie.genre ne 'N/A'}">・ ${movie.genre}</c:if>
                </p>
                <p class="text-meta">
                    <c:if test="${not empty movie.runtime and movie.runtime ne 'N/A'}">${movie.runtime}</c:if>
                    <c:if test="${not empty movie.rated and movie.rated ne 'N/A'}">・ ${movie.rated}</c:if>
                </p>

                <div class="d-flex align-items-center mb-3">
                    <i class="fas fa-star text-warning me-1"></i>
                    <strong>평균 <c:choose><c:when test="${movie.rating == 0.0}">-</c:when><c:otherwise><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></c:otherwise></c:choose></strong>
                </div>

                <div class="mt-3">
                    <c:choose>
                        <c:when test="${not empty sessionScope.loginMember && sessionScope.userRole == 'MEMBER' && not empty movie.id}">
                            <div class="like-component active" id="likeComponent"><i class="like-icon <c:if test='${movie.isLiked()}'>fas fa-heart</c:if><c:if test='${!movie.isLiked()}'>far fa-heart</c:if>"></i><span class="like-count" id="likeCountSpan">총 ${movie.likeCount}명 찜</span></div>
                        </c:when>
                        <c:when test="${empty sessionScope.loginMember && not empty movie.id}"><div class="like-component login-required" id="loginRequiredLike"><i class="like-icon far fa-heart"></i><span class="like-count">총 ${movie.likeCount}명 찜</span></div></c:when>
                        <c:otherwise><div class="like-component disabled"><i class="like-icon far fa-heart"></i><span class="like-count"><c:if test="${empty movie.id}">기능 사용 불가</c:if><c:if test="${not empty movie.id}">관리자 찜 불가</c:if></span></div></c:otherwise>
                    </c:choose>
                </div>
                
                <div class="mt-4">
                    <p style="opacity: 0.9; line-height: 1.6;">${movie.overview}</p>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container my-5">
    <div class="row g-5">
        <div class="col-lg-8 main-content-col">
            
           <div class="card border">
                <div class="card-body p-4">
                    <div class="row">
                        <div class="col-lg-6 <c:if test='${not empty sessionScope.loginMember}'>border-end-lg</c:if>">
                             <h5 class="mb-3">내 평가</h5>
                             <div class="score-input-panel">
                                <div class="score-row border-0">
                                    <div class="label"><i class="fas fa-star text-warning me-1"></i>만족도</div>
                                    <div class="avg-score">평균 <c:choose><c:when test="${movie.rating == 0.0}">N/A</c:when><c:otherwise><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></c:otherwise></c:choose></div>
                                    <div class="input-area"><c:import url="/review/rating"><c:param name="movieId" value="${movie.id}" /></c:import></div>
                                </div>
                                <div class="score-row border-0">
                                    <div class="label"><i class="bi bi-exclamation-triangle-fill text-danger me-1"></i>폭력성</div>
                                    <div class="avg-score">평균 <c:choose><c:when test="${movie.violence_score_avg == 0.0}">N/A</c:when><c:otherwise><fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></c:otherwise></c:choose></div>
                                    <div class="input-area"><c:import url="/review/violence"><c:param name="movieId" value="${movie.id}" /></c:import></div>
                                </div>
                                <div class="score-row border-0">
                                    <div class="label"><i class="bi bi-emoji-dizzy-fill text-secondary me-1"></i>공포</div>
                                    <div class="avg-score">평균 <c:choose><c:when test="${avgHorrorScore == 0}">N/A</c:when><c:otherwise><fmt:formatNumber value="${avgHorrorScore}" pattern="#0.0" /></c:otherwise></c:choose></div>
                                    <div class="input-area"><c:import url="/review/HorrorScoreUserView"><c:param name="movieId" value="${movie.id}" /></c:import></div>
                                </div>
                                <div class="score-row border-0">
                                    <div class="label"><i class="bi bi-eye-fill text-warning me-1"></i>선정성</div>
                                    <div class="avg-score">평균 <c:choose><c:when test="${avgSexualScore == 0}">N/A</c:when><c:otherwise><fmt:formatNumber value="${avgSexualScore}" pattern="#0.0" /></c:otherwise></c:choose></div>
                                    <div class="input-area"><c:import url="/review/SexualScoreUserView"><c:param name="movieId" value="${movie.id}" /></c:import></div>
                                </div>
                            </div>
                        </div>
                        <c:if test="${not empty sessionScope.loginMember}">
                        <div class="col-lg-6">
                            <h5 class="mb-3 d-none d-lg-block">내 리뷰</h5>
                            <c:import url="/review/content"><c:param name="movieId" value="${movie.id}" /></c:import>
                        </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- 주의 요소 --%>
            <div class="mt-5">
                <div class="d-flex justify-content-between align-items-center"> 
                    <h5 class="mb-0">⚠️ 주의 요소</h5>
                    <c:if test="${sessionScope.loginMember.role == 'ADMIN'}">
                        <a href="<c:url value='/admin/warnings/${movie.id}' />" class="btn btn-sm btn-outline-dark">관리</a>
                    </c:if>
                </div>
                <c:if test="${not empty groupedWarnings}">
                    <div id="warningSummaryWrapper" class="mt-2">
                        <div id="warningSummary" class="warning-section-compact">
                            <div class="icon-group">
                                <c:forEach items="${groupedWarnings}" var="entry">
                                    <c:choose>
                                        <c:when test="${entry.key == '공포'}"><img src="${pageContext.request.contextPath}/resources/images/movies/horror.png" alt="공포" title="공포"></c:when>
                                        <c:when test="${entry.key == '잔인성'}"><img src="${pageContext.request.contextPath}/resources/images/movies/violence.png" alt="잔인성" title="잔인성"></c:when>
                                        <c:when test="${entry.key == '폭력성'}"><img src="${pageContext.request.contextPath}/resources/images/movies/violence.png" alt="폭력성" title="폭력성"></c:when>
                                        <c:when test="${entry.key == '선정성'}"><img src="${pageContext.request.contextPath}/resources/images/movies/Sexualcontent.png" alt="선정성" title="선정성"></c:when>
                                        <c:when test="${entry.key == '약물'}"><img src="${pageContext.request.contextPath}/resources/images/movies/drug.png" alt="약물" title="약물"></c:when>
                                        <c:when test="${entry.key == '동물'}"><img src="${pageContext.request.contextPath}/resources/images/movies/animal_warning.png" alt="동물" title="동물"></c:when>
                                        <c:otherwise><img src="${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png" alt="기타" title="기타"></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </div>
                        </div>
                        <div id="warningDetails" class="details-content">
                            <ul class="warning-list-flat">
                                <c:forEach items="${groupedWarnings}" var="entry">
                                    <c:forEach items="${entry.value}" var="sentence">
                                        <li>${sentence}</li>
                                    </c:forEach>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>
                </c:if>
            </div>
            
            <%-- 모든 리뷰 목록 --%>
            <c:if test="${not empty reviewList}">
                <div class="mt-5">
                <jsp:include page="/WEB-INF/views/reviewModule/reviewList.jsp">
                    <jsp:param name="movieId" value="${movie.id}" />
                </jsp:include>
                </div>
            </c:if>
        </div>

        <%-- ========== 오른쪽 사이드바 컬럼 (인사이트, 출연진, 스틸컷) ========== --%>
        <div class="col-lg-4 sidebar-col">
            
            <%-- 영화 인사이트 --%>
            <c:if test="${not empty insights}">
            <div class="mb-4">
                <div class="card border-0" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <div class="card-body text-white">
                        <h6 class="card-title mb-3"><i class="fas fa-lightbulb me-2"></i>영화 인사이트</h6>
                        <div class="insights-list"><c:forEach var="insight" items="${insights}"><div class="d-flex align-items-start mb-2"><i class="fas fa-quote-left me-2 mt-1" style="font-size: 0.8em; opacity: 0.7;"></i><span style="line-height: 1.5;">${insight.message}</span></div></c:forEach></div>
                    </div>
                </div>
            </div>
            </c:if>

            <%-- 출연/제작 --%>
            <c:if test="${not empty dbCastList or not empty castAndCrew}">
            <div class="mb-4">
                 <h5 class="mb-3">출연/제작</h5>
                 <ul class="list-unstyled d-flex flex-wrap gap-3 m-0 p-0">
                    <c:if test="${not empty dbCastList}">
                        <c:forEach var="person" items="${dbCastList}">
                            <li style="width:128px; text-align:center;">
                                <a href="${pageContext.request.contextPath}/${person.role_type eq 'DIRECTOR' ? 'directors' : 'actors'}/${person.id}" style="text-decoration:none; color:inherit;">
                                    <c:choose>
                                        <c:when test="${not empty person.profile_image_url}"><img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" class="rounded-circle border mb-2" style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" /></c:when>
                                        <c:otherwise><img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" class="rounded-circle border mb-2" style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" /></c:otherwise>
                                    </c:choose>
                                    <div>
                                        <c:choose>
                                            <c:when test="${person.role_type eq 'DIRECTOR'}"><span class="badge bg-primary">감독</span></c:when>
                                            <c:when test="${person.role_type eq 'ACTOR'}"><span class="badge bg-secondary">배우</span></c:when>
                                            <c:when test="${person.role_type eq 'VOICE'}"><span class="badge bg-success">성우</span></c:when>
                                            <c:otherwise><span class="badge bg-light text-dark">${person.role_type}</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">${person.name}</div>
                                    <div style="color:#888; font-size:0.93em;"><c:if test="${not empty person.role_name}">${person.role_name}</c:if></div>
                                </a>
                            </li>
                        </c:forEach>
                    </c:if>
                    <c:if test="${empty dbCastList && not empty castAndCrew}">
                        <c:forEach var="person" items="${castAndCrew}">
                            <li style="width:128px; text-align:center;"><a style="text-decoration:none; color:inherit;">
                                    <c:choose>
                                        <c:when test="${not empty person.profile_path}"><img src="https://image.tmdb.org/t/p/w185/${person.profile_path}" class="rounded-circle border mb-2" style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" /></c:when>
                                        <c:otherwise><img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" class="rounded-circle border mb-2" style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" /></c:otherwise>
                                    </c:choose>
                                    <div>
                                        <c:choose>
                                            <c:when test="${person.type eq 'DIRECTOR'}"><span class="badge bg-primary">감독</span></c:when>
                                            <c:when test="${person.type eq 'ACTOR'}"><span class="badge bg-secondary">배우</span></c:when>
                                            <c:when test="${person.type eq 'VOICE'}"><span class="badge bg-success">성우</span></c:when>
                                            <c:otherwise><span class="badge bg-light text-dark">${person.type}</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">${person.name}</div>
                                    <div style="color:#888; font-size:0.93em;"><c:if test="${not empty person.role}">${person.role}</c:if></div>
                                </a></li>
                        </c:forEach>
                    </c:if>
                </ul>
            </div>
            </c:if>

            <%-- 스틸컷 --%>
            <c:if test="${not empty movieImages}">
            <div class="mb-4">
                <h5 class="mb-3">스틸컷</h5>
                <div class="row g-2">
                    <c:forEach var="img" items="${movieImages}" varStatus="status">
                        <div class="col-6 ${status.index >= 6 ? 'd-none more-gallery' : ''}">
                           <img src="https://image.tmdb.org/t/p/w500${img.imageUrl}" alt="스틸컷" class="img-fluid rounded shadow-sm" style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#imageModal" data-bs-image="https://image.tmdb.org/t/p/original${img.imageUrl}">
                        </div>
                    </c:forEach>
                </div>
                <c:if test="${fn:length(movieImages) > 6}">
                    <div class="mt-2 text-center"><button id="toggleGalleryBtn" class="btn btn-outline-secondary btn-sm">더 보기</button></div>
                </c:if>
            </div>
            </c:if>
        </div>
    </div>
</div>

<%-- 추천 영화 --%>
<c:if test="${not empty recommended}">
<div class="container mb-5">
    <hr class="my-5">
    <h5>비슷한 영화</h5>
    <p class="text-muted"><c:choose><c:when test="${empty sessionScope.loginMember}">평가를 해주시면 취향에 맞는 영화를 추천해 드립니다.</c:when><c:otherwise>${sessionScope.loginMember.id}님의 취향에 맞는 영화를 추천해드릴게요</c:otherwise></c:choose></p>
    <div class="d-flex flex-wrap gap-3">
        <c:forEach var="rec" items="${recommended}">
            <div class="movie-card" style="width: 120px; font-size: 0.8rem;">
                <a href="${pageContext.request.contextPath}/movies/${rec.movieId}" class="text-decoration-none text-dark">
                    <div class="rounded overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty rec.posterPath and fn:startsWith(rec.posterPath, 'http')}"><img src="${rec.posterPath}" class="w-100" style="height: 160px; object-fit: cover;"></c:when>
                            <c:when test="${not empty rec.posterPath}"><img src="https://image.tmdb.org/t/p/w185/${rec.posterPath}" class="w-100" style="height: 160px; object-fit: cover;"></c:when>
                            <c:otherwise><img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" class="w-100" style="height: 160px; object-fit: cover;"></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="mt-1">
                        <div class="text-truncate fw-semibold" title="${rec.title}">${rec.title}</div>
                        <div class="text-muted small">${rec.rated}</div>
                        <div class="text-muted small"><c:forEach var="genre" items="${rec.genres}"><span>${genre} </span></c:forEach></div>
                    </div>
                </a>
            </div>
        </c:forEach>
    </div>
</div>
</c:if>

<%-- 모달 및 푸터, 스크립트 --%>
<div class="d-block d-md-none" style="height: 80px;"></div>
<div class="modal fade" id="imageModal" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-dialog-centered modal-xl modal-fullscreen-sm-down"><div class="modal-content position-relative bg-transparent border-0"><button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Close" style="filter: brightness(0.7); background-color: rgba(255,255,255,0.6);"></button><img id="modalImage" src="" class="img-fluid rounded d-block mx-auto" style="max-height: 95vh; object-fit: contain;"></div></div></div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
<script>
$(document).ready(function() {
    // 주의요소 토글
    $('#warningSummary').on('click', function() { $('#warningDetails').slideToggle(200); });

    // 찜하기 기능
    const likeComponent = $('#likeComponent');
    if (likeComponent.length) {
        likeComponent.data('is-liked', ${movie.isLiked()});
        likeComponent.on({
            mouseenter: function() { $(this).find('.like-icon').toggleClass('fas far'); },
            mouseleave: function() { $(this).find('.like-icon').toggleClass('fas far'); }
        });
        likeComponent.on('click', function() {
            const component = $(this);
            if (component.hasClass('processing')) return;
            component.addClass('processing').css('pointer-events', 'none');
            $.ajax({
                url: '${pageContext.request.contextPath}/movies/${movie.id}/toggleCart', type: 'POST',
                success: function(response) {
                    const isNowLiked = (response.status === 'added');
                    component.data('is-liked', isNowLiked);
                    component.find('.like-icon').attr('class', 'like-icon ' + (isNowLiked ? 'fas fa-heart' : 'far fa-heart'));
                    if (response.newLikeCount !== undefined) { $('#likeCountSpan').text(`총 ${response.newLikeCount}명 찜`); }
                },
                error: function(xhr) { alert("오류 발생"); },
                complete: function() { component.removeClass('processing').css('pointer-events', 'auto'); }
            });
        });
    }

    // 로그인 필요 찜하기 버튼
    $('#loginRequiredLike').on({
        mouseenter: function() { $(this).find('.like-icon').removeClass('far').addClass('fas'); },
        mouseleave: function() { $(this).find('.like-icon').removeClass('fas').addClass('far'); },
        click: function() { alert('로그인해야 찜을 할 수 있어요.'); }
    });

    // 스틸컷 더보기
    $('#toggleGalleryBtn').on('click', function() { $('.more-gallery').toggleClass('d-none'); $(this).text($(this).text() === '더 보기' ? '간단히 보기' : '더 보기'); });
    
    // 이미지 모달
    $('[data-bs-toggle="modal"]').on('click', function() { $('#modalImage').attr('src', $(this).data('bs-image')); });
});
</script>
</body>
</html>