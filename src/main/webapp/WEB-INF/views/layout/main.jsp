<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>?v=home-overview-20260611">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<head>  
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Chiron+Sung+HK:ital,wght@0,200..900;1,200..900&family=Gothic+A1&family=Gowun+Dodum&family=Noto+Sans+KR:wght@100..900&display=swap');
    .btn {
            /* 버튼 글씨 색상 설정 */
            color: #a0a0a0 !important;
            
            /* 버튼 배경을 투명하게 설정 (필요에 따라) */
            background-color: transparent;
            border: none;
            }     
     .bg {
        background-color: #f8f9fa !important;
    }
    .calendar-container {
    background-color: #fff !important;
    padding: 15px; /* Optional: Add some padding around the calendar */
    border-radius: 5px; /* Optional: Add some rounded corners */
}       
/* 캘린더 네비게이션 버튼 스타일 수정 */
    .calendar-nav {
        background-color: #f0f0f0 !important;
        border: none !important; /* 테두리 제거 */
        padding: 5px 10px !important;
        cursor: pointer !important;
        font-size: 0.7em !important;
        border-radius: 8px !important; /* 모서리를 살짝 둥글게 */
    }
    
	.gothic-a1-regular {
	  font-family: "Gothic A1", sans-serif;
	  font-weight: 400;
	  font-style: normal;
	}
	
    </style>
</head>    
<body class="bg">
  <div class="container py-4">

    <section class="home-overview" id="recent-comments" aria-label="PreWatch 홈 요약">
      <div class="home-overview-grid">
        <div class="home-feed-panel">
          <div class="home-panel-heading">
            <div>
              <span class="home-eyebrow">최근 리뷰</span>
              <h2>지금 올라온 영화 이야기</h2>
              <p>만족도만이 아니라 폭력성, 공포, 선정성까지 함께 보고 볼 영화를 골라보세요.</p>
            </div>
            <a href="<c:url value='/movies/all-recent-comments'/>" class="home-panel-link">전체 보기</a>
          </div>

          <div class="home-index-panel" aria-label="PreWatch 평가지수">
            <div class="home-index-heading">
              <strong>PreWatch 평가지수</strong>
              <span>영화를 보기 전 체감 난이도를 나눠 볼 수 있어요.</span>
            </div>

            <div class="home-index-grid">
              <div class="home-index-card home-index-rating">
                <i class="bi bi-star-fill"></i>
                <strong>만족도</strong>
                <span>재미와 재관람 의향</span>
                <em><fmt:formatNumber value="${globalStats.totalUserRatingCount}" pattern="#,##0" />개</em>
              </div>
              <div class="home-index-card home-index-violence">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <strong>폭력성</strong>
                <span>액션과 잔혹 묘사 체감</span>
                <em><fmt:formatNumber value="${globalStats.totalViolenceScoreCount}" pattern="#,##0" />개</em>
              </div>
              <div class="home-index-card home-index-horror">
                <i class="bi bi-emoji-dizzy-fill"></i>
                <strong>공포</strong>
                <span>긴장감과 불안감</span>
                <em><fmt:formatNumber value="${globalStats.totalHorrorScoreCount}" pattern="#,##0" />개</em>
              </div>
              <div class="home-index-card home-index-sexual">
                <i class="bi bi-eye-fill"></i>
                <strong>선정성</strong>
                <span>가족 시청 시 주의</span>
                <em><fmt:formatNumber value="${globalStats.totalSexualScoreCount}" pattern="#,##0" />개</em>
              </div>
            </div>
          </div>

          <div class="home-taste-cta" aria-label="나의 취향 분석">
            <div class="home-taste-copy">
              <strong>영화 5편을 평가하면 취향 리포트가 열려요</strong>
              <span>대표 장르, 점수 성향, 자주 만난 배우와 감독, 찜 목록에 남은 관심사까지 함께 분석합니다.</span>
            </div>
            <div class="home-taste-actions">
              <c:choose>
                <c:when test="${not empty loginMember}">
                  <a href="<c:url value='/member/mypage_taste'/>">취향 리포트 보기</a>
                </c:when>
                <c:otherwise>
                  <button type="button"
                          data-bs-toggle="modal"
                          data-message="로그인 후 영화를 평가하면 취향 리포트를 만들 수 있어요"
                          data-bs-target="#loginModal">
                    로그인하고 시작하기
                  </button>
                </c:otherwise>
              </c:choose>
              <a href="#recommended-ranking" class="home-taste-secondary">평가할 영화 찾기</a>
            </div>
          </div>

          <div class="home-review-list">
            <c:choose>
              <c:when test="${not empty recentComments}">
                <c:forEach var="review" items="${recentComments}">
                  <c:set var="reviewPosterSrc">
                    <c:choose>
                      <c:when test="${not empty review.posterPath and review.posterPath ne 'N/A'}">
                        <c:choose>
                          <c:when test="${fn:startsWith(review.posterPath, 'http://') or fn:startsWith(review.posterPath, 'https://')}">
                            ${review.posterPath}
                          </c:when>
                          <c:otherwise>
                            ${pageContext.request.contextPath}${review.posterPath}
                          </c:otherwise>
                        </c:choose>
                      </c:when>
                      <c:otherwise>
                        ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                      </c:otherwise>
                    </c:choose>
                  </c:set>
                  <a href="${pageContext.request.contextPath}/movies/${review.movieId}" class="home-review-link">
                    <img src="${reviewPosterSrc}" alt="${review.movieName} 포스터" />
                    <span class="home-review-copy">
                      <span class="home-review-meta">${review.memberId} · 만족도 ${review.userRating}/10</span>
                      <strong>${review.movieName}</strong>
                      <span>${review.reviewContent}</span>
                    </span>
                  </a>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="home-empty-note">
                  아직 최근 리뷰가 없습니다. 영화를 평가하면 이곳에 리뷰가 채워집니다.
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <aside class="home-rail" aria-label="영화 요약 목록">
          <div class="home-rail-panel">
            <div class="home-rail-heading">
              <h3>많이 찜한 영화</h3>
              <a href="<c:url value='/movies/all-recommended'/>">더 보기</a>
            </div>
            <div class="home-rank-list">
              <c:set var="topRank" value="0" />
              <c:forEach var="movie" items="${recommendedMovies}" begin="0" end="2">
                <c:set var="topRank" value="${topRank + 1}" />
                <c:set var="rankPosterSrc">
                  <c:choose>
                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                      <c:choose>
                        <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                          ${movie.posterPath}
                        </c:when>
                        <c:otherwise>
                          ${pageContext.request.contextPath}${movie.posterPath}
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    <c:otherwise>
                      ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                    </c:otherwise>
                  </c:choose>
                </c:set>
                <a href="<c:url value='/movies/${movie.id}'/>" class="home-rank-row">
                  <span class="home-rank-number">${topRank}</span>
                  <img src="${rankPosterSrc}" alt="${movie.title} 포스터" />
                  <span>
                    <strong>${movie.title}</strong>
                    <em>
                      <c:choose>
                        <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                        <c:otherwise>등급 미정</c:otherwise>
                      </c:choose>
                      · 평점 <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
                    </em>
                  </span>
                </a>
              </c:forEach>
            </div>
          </div>

          <div class="home-rail-panel">
            <div class="home-rail-heading">
              <h3>지금 사람들은 무엇을 검색할까요?</h3>
              <span class="home-rail-caption">최근 검색어</span>
            </div>
            <c:choose>
              <c:when test="${not empty recentSearchKeywords}">
                <div class="home-search-keywords" id="homeSearchKeywords">
                  <c:forEach var="keyword" items="${recentSearchKeywords}">
                    <c:url var="keywordSearchUrl" value="/search">
                      <c:param name="query" value="${keyword}" />
                    </c:url>
                    <span class="home-search-keyword-item" data-keyword="${fn:escapeXml(keyword)}">
                      <a href="${keywordSearchUrl}" class="home-search-keyword"><c:out value="${keyword}" /></a>
                      <button type="button" class="home-search-keyword-remove" aria-label="${fn:escapeXml(keyword)} 검색어 숨기기">&times;</button>
                    </span>
                  </c:forEach>
                </div>
                <div class="home-empty-note home-search-hidden-empty" id="homeSearchHiddenEmpty">
                  이 브라우저에서 숨긴 검색어입니다. 다른 사람의 검색어 기록은 삭제되지 않습니다.
                </div>
              </c:when>
              <c:otherwise>
                <div class="home-empty-note">검색어가 쌓이면 이곳에 표시됩니다.</div>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="home-rail-panel">
            <div class="home-rail-heading">
              <h3>사람들이 관심 있게 본 영화</h3>
              <span class="home-rail-caption">관심 영화</span>
            </div>
            <c:choose>
              <c:when test="${not empty recentViewedMovies}">
                <div class="home-rank-list">
                  <c:set var="viewRank" value="0" />
                  <c:forEach var="movie" items="${recentViewedMovies}">
                    <c:set var="viewRank" value="${viewRank + 1}" />
                    <c:set var="viewPosterSrc">
                      <c:choose>
                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                          <c:choose>
                            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                              ${movie.posterPath}
                            </c:when>
                            <c:otherwise>
                              ${pageContext.request.contextPath}${movie.posterPath}
                            </c:otherwise>
                          </c:choose>
                        </c:when>
                        <c:otherwise>
                          ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                        </c:otherwise>
                      </c:choose>
                    </c:set>
                    <a href="<c:url value='/movies/${movie.id}'/>" class="home-rank-row">
                      <span class="home-rank-number">${viewRank}</span>
                      <img src="${viewPosterSrc}" alt="${movie.title} 포스터" />
                      <span>
                        <strong>${movie.title}</strong>
                        <em>
                          <c:choose>
                            <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                            <c:otherwise>등급 미정</c:otherwise>
                          </c:choose>
                          · 평점 <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
                        </em>
                      </span>
                    </a>
                  </c:forEach>
                </div>
              </c:when>
              <c:otherwise>
                <div class="home-empty-note">아직 표시할 영화가 없어요.</div>
              </c:otherwise>
            </c:choose>
          </div>
        </aside>
      </div>
    </section>


    <nav class="home-quick-actions" aria-label="홈 바로가기">
      <a href="#home-schedule-panel">개봉 일정</a>
      <a href="#recommended-ranking">인기 영화</a>
      <a href="#admin-recommended-movies">추천 영화</a>
      <c:choose>
        <c:when test="${not empty loginMember}">
          <a href="<c:url value='/member/mypage_taste'/>">나의 취향 분석</a>
        </c:when>
        <c:otherwise>
          <button type="button"
                  data-bs-toggle="modal"
                  data-message="이 기능은 로그인 후 이용하실 수 있어요"
                  data-bs-target="#loginModal">
            나의 취향 분석
          </button>
        </c:otherwise>
      </c:choose>
    </nav>

    <section class="home-board-grid" aria-label="영화 보드">
      <article class="home-board-panel home-schedule-panel" id="home-schedule-panel">
        <div class="home-board-heading">
          <div>
            <span class="home-eyebrow home-eyebrow-blue">개봉 일정</span>
            <h2>다가오는 개봉작</h2>
          </div>
          <a href="<c:url value='/movies/all-upcoming'/>">전체 보기</a>
        </div>

        <div class="home-release-timeline">
          <c:choose>
            <c:when test="${not empty upcomingMovies}">
              <c:forEach var="movie" items="${upcomingMovies}" begin="0" end="11">
                <c:set var="timelinePosterSrc">
                  <c:choose>
                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                      <c:choose>
                        <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                          ${movie.posterPath}
                        </c:when>
                        <c:otherwise>
                          ${pageContext.request.contextPath}${movie.posterPath}
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    <c:otherwise>
                      ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                    </c:otherwise>
                  </c:choose>
                </c:set>
                <a href="<c:url value='/movies/${movie.id}'/>" class="home-release-item">
                  <span class="home-release-dot"></span>
                  <span class="home-release-branch"></span>
                  <span class="home-release-card">
                    <img src="${timelinePosterSrc}" alt="${movie.title} 포스터" />
                    <span class="home-release-copy">
                      <span class="home-release-date">${movie.formattedReleaseDate}</span>
                      <strong>${movie.title}</strong>
                      <em>
                        <c:choose>
                          <c:when test="${movie.dday > 0}">D-${movie.dday}</c:when>
                          <c:when test="${movie.dday == 0}">D-DAY</c:when>
                          <c:otherwise>D+${-movie.dday}</c:otherwise>
                        </c:choose>
                        ·
                        <c:choose>
                          <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                          <c:otherwise>등급 미정</c:otherwise>
                        </c:choose>
                      </em>
                    </span>
                  </span>
                </a>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="home-empty-note">표시할 개봉 일정이 없습니다.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </article>

      <article class="home-board-panel" id="recommended-ranking">
        <div class="home-board-heading">
          <div>
            <span class="home-eyebrow home-eyebrow-orange">인기 영화</span>
            <h2>PreWatch 추천 랭킹</h2>
          </div>
          <a href="<c:url value='/movies/all-recommended'/>">전체 보기</a>
        </div>

        <div class="home-poster-grid">
          <c:set var="rank" value="0" />
          <c:forEach var="movie" items="${recommendedMovies}">
            <c:set var="rank" value="${rank + 1}" />
            <c:set var="posterSrc">
              <c:choose>
                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                  <c:choose>
                    <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                      ${movie.posterPath}
                    </c:when>
                    <c:otherwise>
                      ${pageContext.request.contextPath}${movie.posterPath}
                    </c:otherwise>
                  </c:choose>
                </c:when>
                <c:otherwise>
                  ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                </c:otherwise>
              </c:choose>
            </c:set>
            <a href="<c:url value='/movies/${movie.id}'/>" class="home-poster-card">
              <span class="home-poster-rank">${rank}</span>
              <img src="${posterSrc}" alt="${movie.title} 포스터" />
              <strong>${movie.title}</strong>
              <em>
                <c:choose>
                  <c:when test="${not empty movie.rated}">${movie.rated}</c:when>
                  <c:otherwise>등급 미정</c:otherwise>
                </c:choose>
                · 평점 <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
              </em>
            </a>
          </c:forEach>
        </div>
      </article>

      <article class="home-board-panel" id="admin-recommended-movies">
        <div class="home-board-heading">
          <div>
            <span class="home-eyebrow home-eyebrow-violet">큐레이션</span>
            <h2>PreWatch 추천 영화</h2>
          </div>
        </div>

        <c:choose>
          <c:when test="${not empty adminRecommendedMovies}">
            <div class="home-poster-grid home-poster-grid-compact">
              <c:forEach var="movie" items="${adminRecommendedMovies}" begin="0" end="5">
                <c:set var="posterSrc">
                  <c:choose>
                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                      <c:choose>
                        <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                          ${movie.posterPath}
                        </c:when>
                        <c:otherwise>
                          ${pageContext.request.contextPath}${movie.posterPath}
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    <c:otherwise>
                      ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                    </c:otherwise>
                  </c:choose>
                </c:set>
                <a href="<c:url value='/movies/${movie.id}'/>" class="home-poster-card">
                  <img src="${posterSrc}" alt="${movie.title} 포스터" />
                  <strong>${movie.title}</strong>
                  <em>${movie.year} · ${movie.genre}</em>
                </a>
              </c:forEach>
            </div>
          </c:when>
          <c:otherwise>
            <div class="home-empty-note">아직 추천 영화가 없습니다.</div>
          </c:otherwise>
        </c:choose>
      </article>
    </section>
</div> <%-- .container py-4 닫는 태그 --%>

  <!-- ========== 로그인 모달 ========== -->
    <jsp:include page="/WEB-INF/views/loginModal.jsp" />
  <!-- Bootstrap JS -->
 <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
 <script>
 document.addEventListener('DOMContentLoaded', function () {
   const storageKey = 'prewatch.hiddenRecentSearchKeywords';
   const keywordList = document.getElementById('homeSearchKeywords');
   const emptyNotice = document.getElementById('homeSearchHiddenEmpty');

   if (!keywordList) {
     return;
   }

   // DB 삭제 아님. 이 브라우저에서만 숨김
   function getHiddenKeywords() {
     try {
       return JSON.parse(localStorage.getItem(storageKey) || '[]');
     } catch (error) {
       return [];
     }
   }

   function setHiddenKeywords(keywords) {
     localStorage.setItem(storageKey, JSON.stringify(Array.from(new Set(keywords))));
   }

   function refreshKeywordVisibility() {
     const hiddenKeywords = getHiddenKeywords();
     const keywordItems = Array.from(keywordList.querySelectorAll('.home-search-keyword-item'));

     keywordItems.forEach(function (item) {
       item.hidden = hiddenKeywords.includes(item.dataset.keyword);
     });

     const visibleCount = keywordItems.filter(function (item) {
       return !item.hidden;
     }).length;

     if (emptyNotice) {
       emptyNotice.style.display = visibleCount === 0 ? 'block' : 'none';
     }
   }

   keywordList.addEventListener('click', function (event) {
     const removeButton = event.target.closest('.home-search-keyword-remove');
     if (!removeButton) {
       return;
     }

     event.preventDefault();
     const item = removeButton.closest('.home-search-keyword-item');
     if (!item) {
       return;
     }

     const hiddenKeywords = getHiddenKeywords();
     hiddenKeywords.push(item.dataset.keyword);
     setHiddenKeywords(hiddenKeywords);
     refreshKeywordVisibility();
   });

   refreshKeywordVisibility();
 });
 </script>
