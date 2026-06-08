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
    <link rel="stylesheet" href="<c:url value='/resources/css/rating-score.css'/>">
    <script src="<c:url value='/resources/js/rating-score.js'/>"></script>
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        
        .caution-text {
            font-size: 1em;
            font-weight: 500;
            color: #868e96;
        }
        
        .prewatch-hero {
            position: relative;
            width: 100%;
            height: 50vh;
            min-height: 400px;
            background-size: cover;
            background-position: center 20%;
            color: white;
            display: flex;
            align-items: center;
        }
        
        .prewatch-hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(to top, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.8) 100%);
        }
        
        .prewatch-hero-content {
            position: relative;
            z-index: 2;
            text-shadow: 0 2px 4px rgba(0,0,0,0.5);
        }
        
        .prewatch-hero h1 {
            font-size: 3rem;
            font-weight: 700;
        }
        
        .prewatch-hero p {
            font-size: 1.1rem;
            color: #e9ecef;
        }
        
        .prewatch-main-content {
            background-color: #fff;
            border-bottom: 1px solid #e9ecef;
            padding: 2rem 0;
        }
        
        .main-poster {
            width: 180px;
            border-radius: 4px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .like-component {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border: 1px solid #dee2e6;
            border-radius: 50px;
            transition: all 0.2s ease-in-out;
            user-select: none;
        }
        
        .like-component.active {
            cursor: pointer;
        }
        
        .like-component.active:hover {
            background-color: #f8f9fa;
            border-color: #ced4da;
        }
        
        .like-component.disabled {
            cursor: not-allowed;
            background-color: #e9ecef;
            color: #6c757d;
        }
        
        .like-component.login-required {
            cursor: pointer;
        }
        
        .like-component.login-required:hover {
            background-color: #f8f9fa;
        }
        
        .like-component .like-icon {
            font-size: 1.4em;
        }
        
        .like-component .like-icon.fas {
            color: #dc3545;
        }
        
        .like-component .like-icon.far {
            color: #6c757d;
        }
        
        .like-component .like-count {
            font-size: 0.95em;
            font-weight: 500;
            color: #495057;
        }

        .warning-section-compact {
            padding: 8px;
            border-radius: 8px;
            background-color: transparent;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        
        .warning-section-compact:hover {
            background-color: #f8f9fa;
        }
        
        .icon-group {
            display: inline-flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .icon-group img {
            width: 28px;
            height: 28px;
        }

        .warning-icon-tooltip {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            outline: none;
        }

        .warning-icon-tooltip:hover,
        .warning-icon-tooltip:focus {
            background-color: #f1f3f5;
        }

        .warning-tooltip-bubble {
            --warning-tooltip-shift-x: 0px;
            position: absolute;
            left: 50%;
            bottom: calc(100% + 10px);
            transform: translateX(calc(-50% + var(--warning-tooltip-shift-x))) translateY(4px);
            width: max-content;
            max-width: min(300px, calc(100vw - 24px));
            padding: 10px 12px;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            background-color: #fff;
            color: #212529;
            box-shadow: 0 8px 20px rgba(33, 37, 41, 0.16);
            font-size: 0.85rem;
            line-height: 1.45;
            text-align: left;
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
            transition: opacity 0.15s ease, transform 0.15s ease, visibility 0.15s ease;
            z-index: 20;
        }

        .warning-tooltip-bubble::after {
            content: "";
            position: absolute;
            left: calc(50% - var(--warning-tooltip-shift-x));
            top: 100%;
            transform: translateX(-50%);
            border-width: 6px 6px 0 6px;
            border-style: solid;
            border-color: #fff transparent transparent transparent;
        }

        .warning-icon-tooltip.is-tooltip-ready:hover .warning-tooltip-bubble,
        .warning-icon-tooltip.is-tooltip-ready:focus .warning-tooltip-bubble {
            opacity: 1;
            visibility: visible;
            transform: translateX(calc(-50% + var(--warning-tooltip-shift-x))) translateY(0);
        }

        .warning-tooltip-title {
            display: block;
            margin-bottom: 6px;
            font-weight: 700;
            white-space: nowrap;
        }

        .warning-tooltip-line {
            display: block;
            white-space: normal;
            overflow-wrap: break-word;
        }

        .warning-tooltip-line + .warning-tooltip-line {
            margin-top: 4px;
        }

        .warning-tooltip-hint {
            display: block;
            margin-top: 8px;
            padding-top: 7px;
            border-top: 1px solid #f1f3f5;
            color: #6c757d;
            font-size: 0.78rem;
            white-space: normal;
            overflow-wrap: break-word;
        }
        
        .details-content {
            display: none;
            margin-top: 15px;
            padding: 20px;
            background-color: #fff;
            border: 1px solid #e9ecef;
            border-radius: 8px;
        }
        
        .warning-list-flat {
            padding-left: 20px;
            list-style-type: '✓ ';
            margin: 0;
        }
        
        .warning-list-flat li {
            margin-bottom: 5px;
        }

        .score-input-panel .score-row {
            display: flex;
            align-items: center;
            padding: 4px 0;
            border-bottom: 1px solid #f1f1f1;
        }
        
        .score-input-panel .score-row:last-child {
            border-bottom: none;
        }
        
        .score-input-panel .label {
            flex-shrink: 0;
            width: 70px;
            font-weight: 500;
            font-size: 0.95rem;
            margin-right: 1rem;
        }
        
        .score-input-panel .avg-score {
            flex-shrink: 0;
            width: 70px;
            font-size: 0.9rem;
            color: #6c757d;
        }

        .border-end-lg {
            border-right: 1px solid #dee2e6 !important;
        }
        
        @media (max-width: 991.98px) {
            .border-end-lg {
                border-right: none !important;
                border-bottom: 1px solid #dee2e6;
                padding-bottom: 1.5rem;
                margin-bottom: 1.5rem;
            }
        }
        

    .movie-card:hover {
    transform: scale(1.03);
    box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
    transition: all 0.2s ease-in-out;
	}

    .gallery-nav-btn {
        position: absolute;
        top: 50%;
        z-index: 5;
        width: 44px;
        height: 44px;
        border: 0;
        border-radius: 50%;
        background: rgba(0, 0, 0, 0.55);
        color: #fff;
        transform: translateY(-50%);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: background-color 0.2s ease, opacity 0.2s ease;
    }

    .gallery-nav-btn:hover {
        background: rgba(0, 0, 0, 0.75);
    }

    .gallery-nav-btn:disabled {
        opacity: 0.35;
        cursor: default;
    }

    .gallery-nav-prev {
        left: 1rem;
    }

    .gallery-nav-next {
        right: 1rem;
    }

    .gallery-counter {
        position: absolute;
        bottom: 1rem;
        left: 50%;
        z-index: 5;
        transform: translateX(-50%);
        padding: 0.3rem 0.75rem;
        border-radius: 999px;
        background: rgba(0, 0, 0, 0.55);
        color: #fff;
        font-size: 0.9rem;
    }

    @media (max-width: 576px) {
        .gallery-nav-btn {
            width: 38px;
            height: 38px;
        }

        .gallery-nav-prev {
            left: 0.5rem;
        }

        .gallery-nav-next {
            right: 0.5rem;
        }
    }

    @media (hover: none), (pointer: coarse) {
        .warning-tooltip-bubble {
            display: none;
        }
    }

    </style>
</head>

<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <!-- Hero Section -->
    <c:if test="${not empty backdropPath and backdropPath ne 'null'}">
        <c:choose>
            <c:when test="${fn:startsWith(backdropPath, 'http')}">
                <c:set var="backdropUrl" value="${backdropPath}" />
            </c:when>
            <c:otherwise>
                <c:set var="backdropUrl" value="https://image.tmdb.org/t/p/original${backdropPath}" />
            </c:otherwise>
        </c:choose>
        <div class="prewatch-hero" style="background-image: url('${backdropUrl}');">
            <div class="prewatch-hero-overlay"></div>
            <div class="container prewatch-hero-content">
                <h1>${movie.title}</h1>
                <p>
                    ${movie.director} 감독
                    <c:if test="${not empty movie.releaseDate}">・ ${movie.formattedReleaseDate}</c:if>
                </p>
                <p>
                    <c:if test="${not empty movie.genre and movie.genre ne 'N/A'}">${movie.genre}</c:if>
                    <c:if test="${not empty movie.runtime and movie.runtime ne 'N/A'}">・ ${movie.runtime}</c:if>
                    <c:if test="${not empty movie.rated and movie.rated ne 'N/A'}">・ ${movie.rated}</c:if>
                </p>
            </div>
        </div>
    </c:if>

    <!-- Main Content -->
    <div class="prewatch-main-content">
        <div class="container">
            <div class="row g-4">
                <!-- Left Column: Poster & Like Button -->
                <div class="col-md-3 text-center">
                    <!-- Poster -->
                    <c:choose>
                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                            <c:set var="posterSrc">
                                <c:choose>
                                    <c:when test="${fn:startsWith(movie.posterPath, 'http')}">${movie.posterPath}</c:when>
                                    <c:when test="${fn:startsWith(movie.posterPath, '/resources/')}">${pageContext.request.contextPath}${movie.posterPath}</c:when>
                                    <c:otherwise>https://image.tmdb.org/t/p/w500${movie.posterPath}</c:otherwise>
                                </c:choose>
                            </c:set>
                            <img src="${posterSrc}" alt="${movie.title} 포스터" class="main-poster" />
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" class="main-poster" />
                        </c:otherwise>
                    </c:choose>

                    <!-- Like Button -->
                    <div class="mt-3">
                        <c:choose>
                            <c:when test="${not empty sessionScope.loginMember && sessionScope.userRole == 'MEMBER' && not empty movie.id}">
                                <div class="like-component active" id="likeComponent">
                                    <i class="like-icon <c:if test='${movie.isLiked()}'>fas fa-heart</c:if><c:if test='${!movie.isLiked()}'>far fa-heart</c:if>"></i>
                                    <span class="like-count" id="likeCountSpan">총 ${movie.likeCount}명 찜</span>
                                </div>
                            </c:when>
                            <c:when test="${empty sessionScope.loginMember && not empty movie.id}">
                                <div class="like-component login-required" id="loginRequiredLike">
                                    <i class="like-icon far fa-heart"></i>
                                    <span class="like-count">총 ${movie.likeCount}명 찜</span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="like-component disabled">
                                    <i class="like-icon far fa-heart"></i>
                                    <span class="like-count">
                                        <c:if test="${empty movie.id}">기능 사용 불가</c:if>
                                        <c:if test="${not empty movie.id}">관리자 찜 불가</c:if>
                                    </span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
             

                
                <div class="col-md-9">
                  <!-- Warning Section -->
                <%-- 관리자이거나, 등록된 주의요소가 있을 경우에만 이 섹션을 표시. --%>
                <c:if test="${sessionScope.loginMember.role == 'ADMIN' or not empty groupedWarnings}">
                    <div class="d-flex justify-content-between align-items-center">
                        <strong class="mb-0 caution-text">⚠️ 주의</strong>
                        
                        <%-- 관리자에게는 항상 '관리' 버튼을 표시. --%>
                        <c:if test="${sessionScope.loginMember.role == 'ADMIN'}">
                            <a href="<c:url value='/admin/warnings/${movie.id}' />" class="btn btn-sm btn-outline-dark">관리</a>
                        </c:if>
                    </div>

                    <%-- 등록된 주의요소가 있을 경우에만 아이콘과 상세 내용을 표시. --%>
                    <c:if test="${not empty groupedWarnings}">
                        <div id="warningSummaryWrapper" class="mt-1">
                            <div id="warningSummary" class="warning-section-compact">
                                <div class="icon-group">
                                    <c:forEach items="${groupedWarnings}" var="entry">
                                        <span class="warning-icon-tooltip" tabindex="0" aria-label="${entry.key}">
                                            <c:choose>
                                            <c:when test="${entry.key == '공포'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/ghost.png" alt="공포" title="공포">
                                            </c:when>
                                            <c:when test="${entry.key == '잔인성'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/free-icon-agriculture-11558049.png" alt="잔인성" title="잔인성">
                                            </c:when>
                                            <c:when test="${entry.key == '폭력성'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/stop-violence.png" alt="폭력성" title="폭력성">
                                            </c:when>
                                            <c:when test="${entry.key == '선정성'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/sexual.png" alt="선정성" title="선정성">
                                            </c:when>
                                            <c:when test="${entry.key == '약물'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/no-drugs.png" alt="약물" title="약물">
                                            </c:when>
                                            <c:when test="${entry.key == '동물'}">
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/animal.png" alt="동물" title="동물">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/resources/images/movies/free-icon-chat-box-3221863.png" alt="기타" title="기타">
                                            </c:otherwise>
                                            </c:choose>
                                            <span class="warning-tooltip-bubble" role="tooltip">
                                                <span class="warning-tooltip-title"><c:out value="${entry.key}" /></span>
                                                <c:forEach items="${entry.value}" var="sentence">
                                                    <span class="warning-tooltip-line"><c:out value="${sentence}" /></span>
                                                </c:forEach>
                                                <span class="warning-tooltip-hint">클릭하면 전체 주의 요소를 펼쳐볼 수 있어요.</span>
                                            </span>
                                        </span>
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
                </c:if>
                    <!-- 영화 개봉일 전엔 리뷰나 평점 못쓰게 -->
                    <c:if test="${movie.releaseDate <= today}"> 
                    <div class="card mt-3 border-0">
                        <div class="card-body p-0">
                            <div class="row">
                                <div class="col-lg-6 <c:if test='${not empty sessionScope.loginMember}'>border-end-lg</c:if>">
                                    <div class="score-input-panel">
                                        <!-- Satisfaction Score -->
                                        <div class="score-row border-0">
                                            <div class="label">
                                                <i class="fas fa-star text-warning me-1"></i>만족도
                                            </div>
											<div class="avg-score">
											    평균 
											    <c:choose>
											        <c:when test="${movie.rating > 0.0}">
											            <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
											        </c:when>
											        <c:when test="${movie.tmdbRating > 0.0}">
											            <fmt:formatNumber value="${movie.tmdbRating}" pattern="#0.0" />
											        </c:when>
											        <c:otherwise>N/A</c:otherwise>
											    </c:choose>
											</div>

                                            <div class="input-area">
                                                <c:import url="/review/rating">
                                                    <c:param name="movieId" value="${movie.id}" />
                                                </c:import>
                                            </div>
                                        </div>
                                        
                                        <!-- Violence Score -->
                                        <div class="score-row border-0">
                                            <div class="label">
                                                <i class="bi bi-exclamation-triangle-fill text-danger me-1"></i>폭력성
                                            </div>
 											<div class="avg-score">
                                                평균 
                                                <c:choose>
                                                    <c:when test="${movie.rating == 0.0}">N/A</c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>        
                    
                                            
                                            
                                            <div class="input-area">
                                                <c:import url="/review/violence">
                                                    <c:param name="movieId" value="${movie.id}" />
                                                </c:import>
                                            </div>
                                        </div>
                                        
                                        <!-- Horror Score -->
                                        <div class="score-row border-0">
                                            <div class="label">
                                                <i class="bi bi-emoji-dizzy-fill text-secondary me-1"></i>공포
                                            </div>
                                            <div class="avg-score">
                                                평균 
                                                <c:choose>
                                                    <c:when test="${avgHorrorScore == 0}">N/A</c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${avgHorrorScore}" pattern="#0.0" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="input-area">
                                                <c:import url="/review/HorrorScoreUserView">
                                                    <c:param name="movieId" value="${movie.id}" />
                                                </c:import>
                                            </div>
                                        </div>
                                        
                                        <!-- Sexual Score -->
                                        <div class="score-row border-0">
                                            <div class="label">
                                                <i class="bi bi-eye-fill text-warning me-1"></i>선정성
                                            </div>
                                            <div class="avg-score">
                                                평균 
                                                <c:choose>
                                                    <c:when test="${avgSexualScore == 0}">N/A</c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${avgSexualScore}" pattern="#0.0" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="input-area">
                                                <c:import url="/review/SexualScoreUserView">
                                                    <c:param name="movieId" value="${movie.id}" />
                                                </c:import>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Review Content -->

                                    <div class="col-lg-6">
                                        <c:import url="/review/content">
                                            <c:param name="movieId" value="${movie.id}" />
                                        </c:import>
                                    </div>

                            </div>
                        </div>
                    </div>
                    </c:if>  <!-- 영화 개봉일 전엔 리뷰나 평점 못쓰게 -->

                    <!-- Overview -->
                    <c:if test="${not empty movie.overview}">
                        <div class="mt-3">
                            <p class="text-secondary" style="line-height: 1.6;">${movie.overview}</p>
                        </div>
                    </c:if>
                </div>
            </div>
			<c:if test="${movie.releaseDate <= today}">
            <!-- Bottom Content Row -->
            <div class="row mt-4">
                <div class="col-12">
                    <!-- Insights Section -->
                    <c:if test="${not empty insights}">
                        <div class="card border-0 mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                            <div class="card-body text-white">
                                <h6 class="card-title mb-3">
                                    <i class="fas fa-lightbulb me-2"></i>영화 인사이트
                                </h6>
                                <div class="insights-list">
                                    <c:forEach var="insight" items="${insights}">
                                        <div class="d-flex align-items-start mb-2">
                                            <i class="fas fa-quote-left me-2 mt-1" style="font-size: 0.8em; opacity: 0.7;"></i>
                                            <span style="line-height: 1.5;">${insight.message}</span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>
                   </c:if>
                    
                    <!-- Cast Section -->
                    <c:if test="${not empty dbCastList or not empty tmdbCastList}">
                       
                        <div class="card border-0 mt-4 mb-4">
						<h5 class="mb-2">출연/제작</h5>
						<div class="card-body">
                             
                                <ul class="list-unstyled d-flex flex-wrap gap-3" style="margin-top:8px; padding-left:0;">
                                    <!-- DB Cast List -->
                                    <c:if test="${not empty dbCastList}">
                                        <c:forEach var="person" items="${dbCastList}">
                                            <li style="width:128px; text-align:center;">
                                                <a href="${pageContext.request.contextPath}/${person.role_type eq 'DIRECTOR' ? 'directors' : 'actors'}/${person.id}" 
                                                   style="text-decoration:none; color:inherit;">
                                                    <!-- Profile Image -->
                                                    <c:choose>
                                                        <c:when test="${not empty person.profile_image_url}">
                                                            <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" 
                                                                 class="rounded-circle border mb-2" 
                                                                 style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" 
                                                                 class="rounded-circle border mb-2" 
                                                                 style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                    
                                                    <!-- Role Badge -->
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${person.role_type eq 'DIRECTOR'}">
                                                                <span class="badge bg-primary">감독</span>
                                                            </c:when>
                                                            <c:when test="${person.role_type eq 'ACTOR'}">
                                                                <span class="badge bg-secondary">배우</span>
                                                            </c:when>
                                                            <c:when test="${person.role_type eq 'VOICE'}">
                                                                <span class="badge bg-success">성우</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-light text-dark">${person.role_type}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    
                                                    <!-- Name -->
                                                    <div class="fw-bold text-truncate" 
                                                         style="margin:4px 0 0 0; min-height:22px;" 
                                                         title="${person.name}">
                                                        ${person.name}
                                                    </div>
                                                    
                                                    <!-- Role Name -->
                                                    <div style="color:#888; font-size:0.93em;">
                                                        <c:if test="${not empty person.role_name}">${person.role_name}</c:if>
                                                    </div>
                                                </a>
                                            </li>
                                        </c:forEach>
                                    </c:if>
                                    
                                    <!-- TMDB Cast List (fallback) -->
                                    <c:if test="${empty dbCastList && not empty tmdbCastList}">
                                        <c:forEach var="person" items="${tmdbCastList}">
                                            <li style="width:128px; text-align:center;">
                                                <a style="text-decoration:none; color:inherit;">
                                                    <!-- Profile Image -->
                                                    <c:choose>
                                                        <c:when test="${not empty person.profile_path}">
                                                            <img src="https://image.tmdb.org/t/p/w185/${person.profile_path}" 
                                                                 class="rounded-circle border mb-2" 
                                                                 style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" 
                                                                 class="rounded-circle border mb-2" 
                                                                 style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                    
                                                    <!-- Role Badge -->
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${person.type eq 'DIRECTOR'}">
                                                                <span class="badge bg-primary">감독</span>
                                                            </c:when>
                                                            <c:when test="${person.type eq 'ACTOR'}">
                                                                <span class="badge bg-secondary">배우</span>
                                                            </c:when>
                                                            <c:when test="${person.type eq 'VOICE'}">
                                                                <span class="badge bg-success">성우</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-light text-dark">${person.type}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    
                                                    <!-- Name -->
                                                    <div class="fw-bold text-truncate" 
                                                         style="margin:4px 0 0 0; min-height:22px;" 
                                                         title="${person.name}">
                                                        ${person.name}
                                                    </div>
                                                    
                                                    <!-- Role -->
                                                    <div style="color:#888; font-size:0.93em;">
                                                        <c:if test="${not empty person.role}">${person.role}</c:if>
                                                    </div>
                                                </a>
                                            </li>
                                        </c:forEach>
                                    </c:if>
                                </ul>
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- Review List Section -->
                    <c:if test="${not empty reviewList}">
                        <div class="mb-4">
                            <jsp:include page="/WEB-INF/views/reviewModule/reviewList.jsp">
                                <jsp:param name="movieId" value="${movie.id}" />
                            </jsp:include>
                        </div>
                    </c:if>
                    
                    <!-- Movie Images Gallery -->
                    <c:if test="${not empty movieImages}">
                        <div class="mb-4">
                            <div class="card border-0">
                                <div class="card-body">
                                    <h4>스틸컷</h4>
                                    <div class="row g-2 mt-2">
                                        <c:forEach var="img" items="${movieImages}" varStatus="status">
                                            <div class="col-6 col-md-4 ${status.index >= 6 ? 'd-none more-gallery' : ''}">
                                                <c:set var="galleryThumbSrc">
                                                    <c:choose>
                                                        <c:when test="${fn:startsWith(img.imageUrl, 'http')}">${img.imageUrl}</c:when>
                                                        <c:otherwise>https://image.tmdb.org/t/p/w500${img.imageUrl}</c:otherwise>
                                                    </c:choose>
                                                </c:set>
                                                <c:set var="galleryOriginalSrc">
                                                    <c:choose>
                                                        <c:when test="${fn:startsWith(img.imageUrl, 'http')}">${img.imageUrl}</c:when>
                                                        <c:otherwise>https://image.tmdb.org/t/p/original${img.imageUrl}</c:otherwise>
                                                    </c:choose>
                                                </c:set>
                                                <img src="${galleryThumbSrc}"
                                                     alt="스틸컷"
                                                     class="img-fluid rounded shadow-sm gallery-image"
                                                     style="cursor:pointer"
                                                     data-bs-toggle="modal"
                                                     data-bs-target="#imageModal"
                                                     data-gallery-index="${status.index}"
                                                     data-bs-image="${galleryOriginalSrc}">
                                            </div>
                                        </c:forEach>
                                    </div>
                                    <c:if test="${fn:length(movieImages) > 6}">
                                        <div class="mt-2 text-center">
                                            <button id="toggleGalleryBtn" class="btn btn-outline-secondary btn-sm">더 보기</button>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${movie.releaseDate <= today}">
                    <!-- Recommendations Section -->
					<c:if test="${not empty recommended}">
					    <div class="mb-4">
					        <hr>
					        <p class="fw-bold mb-3">
					            <c:choose>
					                <c:when test="${empty sessionScope.loginMember}">
					                    비슷한 영화
					                </c:when>
					                <c:otherwise>
					                    ${sessionScope.loginMember.id}님의 취향에 맞는 영화를 추천해드릴게요
					                </c:otherwise>
					            </c:choose>
					        </p>
					
					        <div class="row g-3">
					            <c:forEach var="rec" items="${recommended}">
							    <div class="col-6 col-sm-4 col-md-3 col-lg-2">
							        <div class="card border-0 shadow-sm h-100 movie-card">
							            <a href="${pageContext.request.contextPath}/movies/${rec.movieId}" class="text-decoration-none text-dark">
							                <c:choose>
											    <c:when test="${not empty rec.posterPath and fn:startsWith(rec.posterPath, 'http')}">
											        <img src="${rec.posterPath}" class="card-img-top" style="height: 300px; object-fit: cover;">
											    </c:when>
											    <c:when test="${not empty rec.posterPath}">
											        <img src="https://image.tmdb.org/t/p/w342/${rec.posterPath}" class="card-img-top" style="height: 300px; object-fit: cover;">
											    </c:when>
											    <c:otherwise>
											        <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>"
											             class="card-img-top" style="height: 300px; object-fit: cover;">
											    </c:otherwise>
											</c:choose>
							                <div class="card-body p-2 text-center">
							                    <h6 class="card-title text-truncate fw-semibold mb-1" title="${rec.title}">
							                        ${rec.title}
							                    </h6>
							                    <div class="text-secondary small">
							                        <i class="fas fa-star"></i>
							                        <c:choose>
							                            <c:when test="${rec.userRatingAvg > 0}">
							                                <fmt:formatNumber value="${rec.userRatingAvg}" pattern="#0.0" />
							                            </c:when>
							                            <c:otherwise>N/A</c:otherwise>
							                        </c:choose>
							                    </div>
							                </div>
							            </a>
							        </div>
							    </div>
							</c:forEach>
					        </div>
					    </div>
					</c:if>
                </div>
               </c:if>
            </div>
        </div>
    </div>

    <!-- Mobile Spacing -->
    <div class="d-block d-md-none" style="height: 80px;"></div>
    
    <!-- Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl modal-fullscreen-sm-down">
            <div class="modal-content position-relative bg-transparent border-0">
                <button type="button" 
                        class="btn-close position-absolute top-0 end-0 m-3" 
                        data-bs-dismiss="modal" 
                        aria-label="Close" 
                        style="filter: brightness(0.7); background-color: rgba(255,255,255,0.6); z-index: 6;">
                </button>
                <button type="button" id="modalPrevImage" class="gallery-nav-btn gallery-nav-prev" aria-label="이전 이미지" title="이전 이미지">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <button type="button" id="modalNextImage" class="gallery-nav-btn gallery-nav-next" aria-label="다음 이미지" title="다음 이미지">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <img id="modalImage" 
                     src="" 
                     class="img-fluid rounded d-block mx-auto" 
                     style="max-height: 95vh; object-fit: contain;">
                <div id="galleryCounter" class="gallery-counter"></div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
    
    <script>
    $(document).ready(function() {
        // Warning Details Toggle
        $('#warningSummary .warning-icon-tooltip img').removeAttr('title');

        function fitWarningTooltip(trigger) {
            const bubble = trigger.querySelector('.warning-tooltip-bubble');
            const container = document.getElementById('warningSummary');
            if (!bubble || !container) {
                return;
            }

            trigger.classList.remove('is-tooltip-ready');
            const containerRect = container.getBoundingClientRect();
            const maxWidth = Math.max(120, Math.min(300, containerRect.width - 16));
            bubble.style.maxWidth = maxWidth + 'px';
            bubble.style.setProperty('--warning-tooltip-shift-x', '0px');

            requestAnimationFrame(function() {
                const nextContainerRect = container.getBoundingClientRect();
                const bubbleRect = bubble.getBoundingClientRect();
                const leftLimit = Math.max(nextContainerRect.left + 8, 8);
                const rightLimit = Math.min(nextContainerRect.right - 8, window.innerWidth - 8);
                let shiftX = 0;

                if (bubbleRect.left < leftLimit) {
                    shiftX = leftLimit - bubbleRect.left;
                } else if (bubbleRect.right > rightLimit) {
                    shiftX = rightLimit - bubbleRect.right;
                }

                bubble.style.setProperty('--warning-tooltip-shift-x', Math.round(shiftX) + 'px');
                trigger.classList.add('is-tooltip-ready');
            });
        }

        $('#warningSummary').on('mouseenter focusin', '.warning-icon-tooltip', function() {
            fitWarningTooltip(this);
        });

        $('#warningSummary').on('mouseleave focusout', '.warning-icon-tooltip', function() {
            this.classList.remove('is-tooltip-ready');
        });

        $(window).on('resize', function() {
            const activeTooltip = $('#warningSummary .warning-icon-tooltip:hover, #warningSummary .warning-icon-tooltip:focus').get(0);
            if (activeTooltip) {
                fitWarningTooltip(activeTooltip);
            }
        });

        $('#warningSummary').on('click', function() {
            $('#warningDetails').slideToggle(200);
        });

        // Like Component Functionality
        const likeComponent = $('#likeComponent');
        if (likeComponent.length) {
            likeComponent.data('is-liked', ${movie.isLiked()});
            
            // Hover Effects
            // Click Handler
            likeComponent.on('click', function() {
                const component = $(this);
                if (component.hasClass('processing')) return;
                
                component.addClass('processing').css('pointer-events', 'none');
                
                $.ajax({
                    url: '${pageContext.request.contextPath}/movies/${movie.id}/toggleCart',
                    type: 'POST',
                    success: function(response) {
                        const isNowLiked = (response.status === 'added');
                        component.data('is-liked', isNowLiked);
                        component.find('.like-icon').attr('class', 'like-icon ' + (isNowLiked ? 'fas fa-heart' : 'far fa-heart'));
                        
                        if (response.newLikeCount !== undefined) {
                            $('#likeCountSpan').text(`총 ${response.newLikeCount}명 찜`);
                        }
                    },
                    error: function(xhr) {
                        const message = xhr.responseJSON && xhr.responseJSON.message
                            ? xhr.responseJSON.message
                            : "찜 처리 중 오류가 발생했습니다.";
                        alert(message);
                    },
                    complete: function() {
                        component.removeClass('processing').css('pointer-events', 'auto');
                    }
                });
            });
        }

        // Login Required Like Component
        $('#loginRequiredLike').on({
            mouseenter: function() {
                $(this).find('.like-icon').removeClass('far').addClass('fas');
            },
            mouseleave: function() {
                $(this).find('.like-icon').removeClass('fas').addClass('far');
            },
            click: function() {
                if (window.openPrewatchLoginModal) {
                    window.openPrewatchLoginModal({
                        message: '찜하려면 로그인이 필요해요.'
                    });
                }
            }
        });

        // Gallery Toggle
        $('#toggleGalleryBtn').on('click', function() {
            $('.more-gallery').toggleClass('d-none');
            $(this).text($(this).text() === '더 보기' ? '간단히 보기' : '더 보기');
        });

        const galleryImages = $('.gallery-image').map(function() {
            return $(this).data('bs-image');
        }).get();
        let currentGalleryIndex = 0;

        function showGalleryImage(index) {
            if (!galleryImages.length) return;

            currentGalleryIndex = (index + galleryImages.length) % galleryImages.length;
            $('#modalImage').attr('src', galleryImages[currentGalleryIndex]);
            $('#galleryCounter').text((currentGalleryIndex + 1) + ' / ' + galleryImages.length);
            $('#modalPrevImage, #modalNextImage, #galleryCounter').toggle(galleryImages.length > 1);
        }

        $('.gallery-image').on('click', function() {
            const clickedIndex = parseInt($(this).data('gallery-index'), 10);
            showGalleryImage(Number.isNaN(clickedIndex) ? 0 : clickedIndex);
        });

        $('#modalPrevImage').on('click', function(event) {
            event.preventDefault();
            event.stopPropagation();
            showGalleryImage(currentGalleryIndex - 1);
        });

        $('#modalNextImage').on('click', function(event) {
            event.preventDefault();
            event.stopPropagation();
            showGalleryImage(currentGalleryIndex + 1);
        });

        $(document).on('keydown', function(event) {
            if (!$('#imageModal').hasClass('show') || galleryImages.length <= 1) return;

            if (event.key === 'ArrowLeft') {
                showGalleryImage(currentGalleryIndex - 1);
            } else if (event.key === 'ArrowRight') {
                showGalleryImage(currentGalleryIndex + 1);
            }
        });
    });
    </script>
</body>
</html>
