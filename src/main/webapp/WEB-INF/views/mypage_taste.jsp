<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>나의 취향 분석 리포트</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
       * {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --primary-color: #667eea;
            --secondary-color: #764ba2;
            --text-dark: #2c3e50;
            --text-muted: #6c757d;
            --bg-light: #f8f9fa;
            --shadow-soft: 0 0.5rem 1rem rgba(0, 0, 0, 0.08);
            --shadow-card: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.05);
            --border-radius: 1rem;
        }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            line-height: 1.8;
            color: var(--text-dark);
        }

        .main-container {
            min-height: calc(100vh - 120px);
            padding: 1.5rem 0;
        }

        .taste-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-soft);
            border: none;
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .page-header {
            background: var(--primary-gradient);
            color: white;
            padding: 1.5rem 0;
            text-align: center;
            margin-bottom: 0;
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 0;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .taste-title-section {
            background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
            padding: 2.5rem;
            text-align: center;
            border-bottom: 1px solid #e9ecef;
        }

        .taste-title {
            font-size: 2rem;
            font-weight: 600;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
            line-height: 1.4;
        }

        .section-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-card);
            border: none;
            margin-bottom: 1.5rem;
            overflow: hidden;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .section-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-soft);
        }

        .section-header {
            background: var(--bg-light);
            padding: 1.5rem 2rem 1rem 2rem;
            border-bottom: 1px solid #e9ecef;
        }

        .section-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin: 0;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .section-content {
            padding: 2rem;
            line-height: 1.9;
        }

        .keyword-container {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-top: 1rem;
        }

        .keyword {
            background: linear-gradient(135deg, #667eea20 0%, #764ba220 100%);
            color: var(--primary-color);
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            font-weight: 500;
            font-size: 0.9rem;
            border: 1px solid #667eea30;
            transition: all 0.2s ease;
        }

        .keyword:hover {
            background: var(--primary-gradient);
            color: white;
            transform: translateY(-1px);
        }

        .person-card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            border-left: 4px solid var(--primary-color);
            transition: all 0.2s ease;
        }

        .person-card:hover {
            background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
            transform: translateX(4px);
        }

        .person-avatar {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 50%;
            border: 3px solid white;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            margin-right: 1.5rem;
            flex-shrink: 0;
        }

        .person-info {
            display: flex;
            align-items: center;
        }

        .insight-highlight {
            color: #28a745;
            font-weight: 600;
            background: #28a74515;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
        }

        .preference-list {
            list-style: none;
            padding: 0;
        }

        .preference-item {
            padding: 1rem;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 0.5rem;
            margin-bottom: 0.75rem;
            border-left: 3px solid var(--primary-color);
            transition: all 0.2s ease;
        }

        .preference-item:hover {
            background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
            transform: translateX(4px);
        }

        .recommendation-card {
            background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);
            border: 1px solid #667eea30;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .recommendation-title {
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .initial-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--text-muted);
        }

        .initial-state .display-1 {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            opacity: 0.3;
        }

        .badge-custom {
            background: var(--primary-gradient);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            font-weight: 500;
        }

        .fade-in {
            animation: fadeIn 0.6s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .gradient-text {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .page-title {
                font-size: 2rem;
            }
            .taste-title {
                font-size: 1.5rem;
            }
            .section-content {
                padding: 1.5rem;
            }
            .person-avatar {
                width: 60px;
                height: 60px;
                margin-right: 1rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="main-container">
        <div class="container">
            <!-- Page Header -->
            <div class="taste-card fade-in">
                <div class="page-header">
                    <h1 class="page-title">
                        <i class="bi bi-person-heart me-2"></i>My Taste Profile
                    </h1>
                </div>

                <c:choose>
                    <c:when test="${not tasteReport.isInitialReport()}">
                        <!-- Taste Title Section -->
                        <div class="taste-title-section">
                            <h2 class="taste-title">"${tasteReport.title}"</h2>
                        </div>

                        <div class="row g-4 p-4">
                            <!-- Keywords Section -->
                            <div class="col-12">
                                <div class="section-card fade-in">
                                    <div class="section-header">
                                        <h3 class="section-title">
                                            <i class="bi bi-tags-fill text-primary"></i>
                                            당신의 취향 키워드
                                        </h3>
                                    </div>
                                    <div class="section-content">
                                        <p class="mb-3 text-muted">가장 자주 선택하고 높은 평점을 준 장르와 스타일입니다.</p>
                                        <div class="keyword-container">
                                            <c:forEach var="genre" items="${tasteReport.keywords.topGenres}">
                                                <span class="keyword">#${genre}</span>
                                            </c:forEach>
                                            <span class="keyword">${tasteReport.keywords.style}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Analysis Section -->
                            <div class="col-12">
                                <div class="section-card fade-in">
                                    <div class="section-header">
                                        <h3 class="section-title">
                                            <i class="bi bi-graph-up text-success"></i>
                                            상세 취향 분석
                                        </h3>
                                    </div>
                                    <div class="section-content">
                                        <c:if test="${not empty tasteReport.analysis.strengths}">
                                            <div class="mb-4">
                                                <h5 class="gradient-text mb-3">
                                                    <i class="bi bi-check-circle-fill me-2"></i>강점
                                                </h5>
                                                <p class="fs-6">당신은 일반 관객보다 
                                                    <c:forEach var="s" items="${tasteReport.analysis.strengths}" varStatus="status">
                                                        <span class="badge-custom">${s}</span><c:if test="${not status.last}">, </c:if>
                                                    </c:forEach>
                                                    요소가 강한 영화에서 큰 만족감을 얻습니다.
                                                </p>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${not empty tasteReport.analysis.weaknesses}">
                                            <div class="mb-4">
                                                <h5 class="text-warning mb-3">
                                                    <i class="bi bi-exclamation-triangle-fill me-2"></i>주의
                                                </h5>
                                                <p class="fs-6">
                                                    <c:forEach var="w" items="${tasteReport.analysis.weaknesses}" varStatus="status">
                                                        <span class="badge text-bg-warning">${w}</span><c:if test="${not status.last}">, </c:if>
                                                    </c:forEach>
                                                    요소가 두드러지는 영화는 불편하게 느낄 수 있으니 참고하세요.
                                                </p>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${empty tasteReport.analysis.strengths and empty tasteReport.analysis.weaknesses}">
                                            <div class="mb-4">
                                                <h5 class="text-info mb-3">
                                                    <i class="bi bi-balance-scale me-2"></i>균형잡힌 취향
                                                </h5>
                                                <p class="fs-6">모든 요소를 고르게 즐기는 균형잡힌 시각을 가졌습니다. 뚜렷한 호불호보다는 영화의 전체적인 완성도를 중요하게 생각합니다.</p>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${not empty tasteReport.analysis.specialInsight}">
                                            <div class="alert alert-info border-0" style="background: linear-gradient(135deg, #17a2b810 0%, #17a2b820 100%);">
                                                <h5 class="alert-heading">
                                                    <i class="bi bi-lightbulb-fill me-2"></i>특별한 발견
                                                </h5>
                                                <p class="mb-0">${tasteReport.analysis.specialInsight}</p>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <!-- Frequent Persons Section -->
                            <div class="col-12">
                                <div class="section-card fade-in">
                                    <div class="section-header">
                                        <h3 class="section-title">
                                            <i class="bi bi-people-fill text-danger"></i>
                                            영화 속 인물과의 인연
                                        </h3>
                                    </div>
                                   <div class="section-content">
									    <c:set var="mrd" value="${tasteReport.frequentPersons.mostReviewedDirector}" />
									    <c:set var="hrd" value="${tasteReport.frequentPersons.highlyRatedDirector}" />
									    <c:set var="mra" value="${tasteReport.frequentPersons.mostReviewedActor}" />
									    <c:set var="hra" value="${tasteReport.frequentPersons.highlyRatedActor}" />
									
									    <!-- Most Reviewed Director -->
									    <c:if test="${not empty mrd}">
									        <a href="${pageContext.request.contextPath}/directors/${mrd.id}" class="text-decoration-none text-reset d-block">
									            <div class="person-card">
									                <div class="person-info">
									                    <c:if test="${not empty mrd.imageUrl}">
									                        <img src="https://image.tmdb.org/t/p/w300${mrd.imageUrl}" 
									                             alt="${mrd.name}" class="person-avatar">
									                    </c:if>
									                    <div class="flex-grow-1">
									                        <h5 class="mb-2">
									                            <i class="bi bi-camera-reels me-2 text-primary"></i>
									                            <span class="gradient-text">${mrd.name}</span> 감독
									                        </h5>
									                        <p class="mb-2">당신이 평가한 영화들 중 이 감독의 작품이 가장 많았습니다.</p>
									                        <c:if test="${not empty hrd and mrd.id == hrd.id}">
									                            <p class="insight-highlight mb-0">
									                                <i class="bi bi-star-fill me-1"></i>
									                                실제로도 이 감독의 작품들에 8점 이상의 높은 점수를 가장 많이 부여했습니다.
									                            </p>
									                        </c:if>
									                    </div>
									                </div>
									            </div>
									        </a>
									    </c:if>
									
									    <!-- Highly Rated Director (if different) -->
									    <c:if test="${not empty hrd and (empty mrd or mrd.id != hrd.id)}">
									        <a href="${pageContext.request.contextPath}/directors/${hrd.id}" class="text-decoration-none text-reset d-block">
									            <div class="person-card">
									                <div class="person-info">
									                    <c:if test="${not empty hrd.imageUrl}">
									                        <img src="https://image.tmdb.org/t/p/w300${hrd.imageUrl}" 
									                             alt="${hrd.name}" class="person-avatar">
									                    </c:if>
									                    <div class="flex-grow-1">
									                        <h5 class="mb-2">
									                            <i class="bi bi-camera-reels me-2 text-warning"></i>
									                            <span class="gradient-text">${hrd.name}</span> 감독
									                        </h5>
									                        <p class="insight-highlight mb-0">
									                            <i class="bi bi-star-fill me-1"></i>
									                            이 감독의 작품들에 높은 만족도를 보였습니다.
									                        </p>
									                    </div>
									                </div>
									            </div>
									        </a>
									    </c:if>
									
									    <!-- Most Reviewed Actor -->
									    <c:if test="${not empty mra}">
									        <a href="${pageContext.request.contextPath}/actors/${mra.id}" class="text-decoration-none text-reset d-block">
									            <div class="person-card">
									                <div class="person-info">
									                    <c:if test="${not empty mra.imageUrl}">
									                        <img src="https://image.tmdb.org/t/p/w300${mra.imageUrl}" 
									                             alt="${mra.name}" class="person-avatar">
									                    </c:if>
									                    <div class="flex-grow-1">
									                        <h5 class="mb-2">
									                            <i class="bi bi-person-fill me-2 text-primary"></i>
									                            <span class="gradient-text">${mra.name}</span>
									                        </h5>
									                        <p class="mb-2">평가해주신 작품에서 가장 자주 등장한 배우입니다.</p>
									                        <c:if test="${not empty hra and mra.id == hra.id}">
									                            <p class="insight-highlight mb-0">
									                                <i class="bi bi-star-fill me-1"></i>
									                                이 배우가 출연한 영화들에 8점 이상의 점수를 가장 많이 주셨네요.
									                            </p>
									                        </c:if>
									                    </div>
									                </div>
									            </div>
									        </a>
									    </c:if>
									
									    <!-- Highly Rated Actor (if different) -->
									    <c:if test="${not empty hra and (empty mra or mra.id != hra.id)}">
									        <a href="${pageContext.request.contextPath}/actors/${hra.id}" class="text-decoration-none text-reset d-block">
									            <div class="person-card">
									                <div class="person-info">
									                    <c:if test="${not empty hra.imageUrl}">
									                        <img src="https://image.tmdb.org/t/p/w300${hra.imageUrl}" 
									                             alt="${hra.name}" class="person-avatar">
									                    </c:if>
									                    <div class="flex-grow-1">
									                        <h5 class="mb-2">
									                            <i class="bi bi-person-fill me-2 text-warning"></i>
									                            <span class="gradient-text">${hra.name}</span>
									                        </h5>
									                        <p class="insight-highlight mb-0">
									                            <i class="bi bi-star-fill me-1"></i>
									                            평가해주신 작품에서 이 배우가 출연한 영화들에 높은 만족도를 보였습니다.
									                        </p>
									                    </div>
									                </div>
									            </div>
									        </a>
									    </c:if>
									</div>

                                </div>
                            </div>

                            <!-- Preferences Section -->
                            <div class="col-12">
                                <div class="section-card fade-in">
                                    <div class="section-header">
                                        <h3 class="section-title">
                                            <i class="bi bi-gear-fill text-warning"></i>
                                            당신의 영화 선택 패턴
                                        </h3>
                                    </div>
                                    <div class="section-content">
                                        <p class="mb-4 text-muted">평점과 선택 빈도를 바탕으로 분석한 선호 패턴입니다.</p>
                                        <ul class="preference-list">
                                            <c:if test="${not empty tasteReport.preferences.preferredYear}">
                                                <li class="preference-item">
                                                    <i class="bi bi-calendar-event me-3 text-primary"></i>
                                                    <strong>선호 시대:</strong> <span class="gradient-text">${tasteReport.preferences.preferredYear}</span>에 대한 선호도가 높습니다.
                                                </li>
                                            </c:if>
                                            <c:if test="${not empty tasteReport.preferences.preferredRuntime}">
                                                <li class="preference-item">
                                                    <i class="bi bi-clock me-3 text-primary"></i>
                                                    <strong>선호 길이:</strong> <span class="gradient-text">${tasteReport.preferences.preferredRuntime}</span>에 깊게 몰입하는 경향이 있습니다.
                                                </li>
                                            </c:if>
                                            <c:if test="${not empty tasteReport.activityPattern}">
                                                <li class="preference-item">
                                                    <i class="bi bi-graph-up me-3 text-primary"></i>
                                                    <strong>감상 패턴:</strong> ${tasteReport.activityPattern}.
                                                </li>
                                            </c:if>
                                        </ul>
                                    </div>
                                </div>
                            </div>

                            <!-- Recommendations Section -->
                            <div class="col-12">
                                <div class="section-card fade-in">
                                    <div class="section-header">
                                        <h3 class="section-title">
                                            <i class="bi bi-compass text-info"></i>
                                            다음 영화 선택 가이드
                                        </h3>
                                    </div>
                                    <div class="section-content">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="recommendation-card">
                                                    <div class="recommendation-title">
                                                        <i class="bi bi-shield-check"></i>
                                                        안전한 선택
                                                    </div>
                                                    <p class="mb-0">${tasteReport.recommendation.safeBet}</p>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="recommendation-card">
                                                    <div class="recommendation-title">
                                                        <i class="bi bi-rocket-takeoff"></i>
                                                        새로운 도전
                                                    </div>
                                                    <p class="mb-0">${tasteReport.recommendation.adventurousChoice}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </c:when>
                    <c:otherwise>
                        <!-- Initial State -->
                        <div class="taste-title-section">
                            <h2 class="taste-title">"${tasteReport.title}"</h2>
                        </div>
                        <div class="initial-state">
                            <div class="display-1">
                                <i class="bi bi-film"></i>
                            </div>
                            <h3 class="gradient-text mb-3">취향 분석을 시작해보세요</h3>
                            <p class="fs-5 text-muted">${tasteReport.initialMessage}</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>