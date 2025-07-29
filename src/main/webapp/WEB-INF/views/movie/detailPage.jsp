<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<%System.out.println("영화 상세페이지 진입"); %>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<%-- 폭력성 주의문구 --%>
<c:import url="/review/sensitivity">
    <c:param name="movieId" value="${movie.id}" />
</c:import>   

<%-- <h1>${movie.title}</h1> --%>

<div class="container mt-4">
    <div class="row g-4 align-items-center">
        <!-- 포스터 -->
        <div class="col-12 col-md-4 text-center">
            <c:choose>
                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                    <c:set var="posterSrc">
                        <c:choose>
                            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                ${movie.posterPath}
                            </c:when>
                            <c:otherwise>
                                ${pageContext.request.contextPath}${movie.posterPath}
                            </c:otherwise>
                        </c:choose>
                    </c:set>
                    <img src="${posterSrc}" alt="${movie.title} 포스터" class="img-fluid rounded shadow-sm" />
                </c:when>
                <c:otherwise>
                    <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
                </c:otherwise>
            </c:choose>
        </div>

     <!-- 영화 정보 -->
<div class="col-12 col-md-8">
    <h2 class="mb-3">${movie.title}</h2>
    <p><strong>감독:</strong> ${movie.director}</p>
    <p><strong>연도:</strong> ${movie.year}</p>
    <p><strong>장르:</strong> ${movie.genre}</p>
    
    
    <%-- ⭐ 여기에 연령 등급과 상영 시간 추가 ⭐ --%>
    <p><strong>연령 등급:</strong> 
        <c:choose>
            <c:when test="${not empty movie.rated and movie.rated ne 'N/A'}">
                ${movie.rated}
            </c:when>
            <c:otherwise>
                정보 없음
            </c:otherwise>
        </c:choose>
    </p>
    <p><strong>상영 시간:</strong> 
        <c:choose>
            <c:when test="${not empty movie.runtime and movie.runtime ne 'N/A'}">
                ${movie.runtime}
            </c:when>
            <c:otherwise>
                정보 없음
            </c:otherwise>
        </c:choose>
    </p>
    <%-- ⭐ 추가 끝 ⭐ --%>

    <p>
        <i class="bi-star-fill text-warning me-1"></i>
        <strong>평균 만족도 지수:</strong>
        <c:choose>
            <c:when test="${movie.rating == 0.0}">N/A</c:when>
            <c:otherwise><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></c:otherwise>
        </c:choose>
        / 10.0
    </p>

    <p>
        <i class="bi-exclamation-triangle-fill text-danger me-1"></i>
        <strong>평균 폭력성 지수:</strong>
        <c:choose>
            <c:when test="${movie.violence_score_avg == 0.0}">N/A</c:when>
            <c:otherwise><fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></c:otherwise>
        </c:choose>
        / 10.0
    </p>

    <!-- 07.28 오후 선정성/공포성 평균 추가-->
    <p>
        <i class="bi-eye-fill text-warning me-1"></i>
        <strong>평균 선정성 지수:</strong>
        <c:choose>
            <c:when test="${empty sexualAvg || sexualAvg == 0.0}">N/A</c:when>
            <c:otherwise><fmt:formatNumber value="${sexualAvg}" pattern="#0.0" /></c:otherwise>
        </c:choose>
        / 10.0
    </p>

    <p>
        <i class="bi-emoji-dizzy-fill text-secondary me-1"></i>
        <strong>평균 공포 지수:</strong>
        <c:choose>
            <c:when test="${empty horrorAvg || horrorAvg == 0.0}">N/A</c:when>
            <c:otherwise><fmt:formatNumber value="${horrorAvg}" pattern="#0.0" /></c:otherwise>
        </c:choose>
        / 10.0
    </p> 

    <p><strong>개요:</strong> ${movie.overview}</p>

    <!-- 태그 목록 -->
    <div class="bg-body-bg rounded-3 p-3">
        <c:import url="/review/reviewTagAll">
            <c:param name="movieId" value="${movie.id}" />
        </c:import>
    </div>

    <!-- 찜 버튼 및 개수 -->
    <div class="favorite-button-wrapper">
        <c:if test="${empty movie.id}">
            <button class="favorite-button disabled" disabled>찜 기능 사용 불가 (DB에 없는 영화)</button>
            <span class="like-count-detail">총 0명 찜</span>
        </c:if>
        <c:if test="${not empty sessionScope.loginMember && sessionScope.userRole == 'MEMBER' && not empty movie.id}">
            <button class="favorite-button" id="toggleFavoriteBtn"
                    data-movie-id="${movie.id}"
                    data-is-liked="${movie.isLiked()}">
                <c:choose>
                    <c:when test="${movie.isLiked()}">찜 목록에서 제거</c:when>
                    <c:otherwise>찜 목록에 추가</c:otherwise>
                </c:choose>
            </button>
            <span class="like-count-detail" id="likeCountDetail">총 ${movie.likeCount}명 찜</span>
        </c:if>
        <c:if test="${empty sessionScope.loginMember || sessionScope.userRole == 'ADMIN'}">
            <button class="favorite-button disabled" disabled>
                <c:choose>
                    <c:when test="${empty sessionScope.loginMember}">로그인 후 찜 가능</c:when>
                    <c:otherwise>관리자 계정은 찜 기능 불가</c:otherwise>
                </c:choose>
            </button>
            <span class="like-count-detail">총 ${movie.likeCount}명 찜</span>
        </c:if>
    </div>
</div>

<!-- 감독 표시 -->
<h2>🎬 감독</h2>
<ul>
  <c:choose>
    <c:when test="${not empty dbCastList}">
      <c:forEach var="person" items="${dbCastList}">
        <c:if test="${person.role_type eq 'DIRECTOR'}">
          <li style="margin-bottom: 12px;">
            <a href="${pageContext.request.contextPath}/directors/${person.id}" style="text-decoration:none; color:inherit;">
              <c:choose>
                <c:when test="${not empty person.profile_image_url}">
                  <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" width="80" />
                </c:when>
                <c:otherwise>
                  <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
                </c:otherwise>
              </c:choose>
              <div><strong>${person.name}</strong></div>
            </a>
            <c:if test="${not empty person.role_name}">
              <div style="color:gray;">(${person.role_name})</div>
            </c:if>
          </li>
        </c:if>
      </c:forEach>
    </c:when>
    <c:when test="${not empty castAndCrew}">
      <c:forEach var="person" items="${castAndCrew}">
        <c:if test="${person.type eq 'DIRECTOR'}">
          <li style="margin-bottom: 12px;">
            <c:choose>
              <c:when test="${not empty person.profile_path}">
                <img src="https://image.tmdb.org/t/p/w185/${person.profile_path}" width="80" />
              </c:when>
              <c:otherwise>
                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
              </c:otherwise>
            </c:choose>
            <div><strong>${person.name}</strong></div>
            <c:if test="${not empty person.role}">
              <div style="color:gray;">(${person.role})</div>
            </c:if>
          </li>
        </c:if>
      </c:forEach>
    </c:when>
    <c:otherwise>
      <li>감독 정보 없음</li>
    </c:otherwise>
  </c:choose>
</ul>

<!-- 주요 참여진 표시 -->
<h2>👥 주요 참여진</h2>
<ul>
  <c:choose>
    <c:when test="${not empty dbCastList}">
      <c:forEach var="person" items="${dbCastList}">
        <c:if test="${person.role_type ne 'DIRECTOR'}">
          <li style="margin-bottom: 12px;">
            <a href="${pageContext.request.contextPath}/actors/${person.id}" style="text-decoration:none; color:inherit;">
              <c:choose>
                <c:when test="${not empty person.profile_image_url}">
                  <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" width="80" />
                </c:when>
                <c:otherwise>
                  <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
                </c:otherwise>
              </c:choose>
              <div><strong>${person.name}</strong></div>
            </a>
            <span style="color:gray;">
              <c:choose>
                <c:when test="${person.role_type eq 'ACTOR'}">배우</c:when>
                <c:when test="${person.role_type eq 'VOICE'}">성우</c:when>
                <c:otherwise>${person.role_type}</c:otherwise>
              </c:choose>
              <c:if test="${not empty person.role_name}"> (${person.role_name} 역)</c:if>
            </span>
          </li>
        </c:if>
      </c:forEach>
    </c:when>
    <c:when test="${not empty castAndCrew}">
      <c:forEach var="person" items="${castAndCrew}">
        <c:if test="${person.type ne 'DIRECTOR'}">
          <li style="margin-bottom: 12px;">
            <c:choose>
              <c:when test="${not empty person.profile_path}">
                <img src="https://image.tmdb.org/t/p/w185/${person.profile_path}" width="80" />
              </c:when>
              <c:otherwise>
                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
              </c:otherwise>
            </c:choose>
            <div><strong>${person.name}</strong></div>
            <span style="color:gray;">
              <c:choose>
                <c:when test="${person.type eq 'ACTOR'}">배우</c:when>
                <c:when test="${person.type eq 'VOICE'}">성우</c:when>
                <c:otherwise>${person.type}</c:otherwise>
              </c:choose>
              <c:if test="${not empty person.role}"> (${person.role} 역)</c:if>
            </span>
          </li>
        </c:if>
      </c:forEach>
    </c:when>
    <c:otherwise>
      <li>출연진 정보 없음</li>
    </c:otherwise>
  </c:choose>
</ul>


	
	                
	<!-- 별점 작성 -->
	<c:if test="${not empty sessionScope.loginMember}">
	    <div class="container mt-3">
	        <div class="bg-body-bg rounded-3 p-3">
	                <h6 class="mb-2 fw-bold"><i class="fas fa-star text-warning me-1"></i>만족도 평가</h5>
	                <c:import url="/review/rating">
	                    <c:param name="movieId" value="${movie.id}" />
	                </c:import>
	        </div>
	    </div>
	</c:if>
	
	<!-- 폭력성 작성 -->
	<c:if test="${not empty sessionScope.loginMember}">
	    <div class="container mt-3">
	        <div class="bg-body-bg rounded-3 p-3">
	                <h6 class="mb-2 fw-bold"><i class="fas fa-bolt text-danger me-1"></i>폭력성 평가</h5>
	                <c:import url="/review/violence">
	                    <c:param name="movieId" value="${movie.id}" />
	                </c:import>
	        </div>
	    </div>
	</c:if>
	
		<!-- 공포지수 작성 -->
		<c:if test="${not empty sessionScope.loginMember}">
		    <div class="container mt-3">
		        <div class="bg-body-bg rounded-3 p-3">
		                <h6 class="mb-2 fw-bold"><i class="fas fa-bolt text-danger me-1"></i>공포지수 평가</h5>
		                <c:import url="/review/saveHorrorUserScore">
		                    <c:param name="movieId" value="${movie.id}" />
		                </c:import>
		        </div>
		    </div>
		</c:if>
		
		<!-- 선정성 지수 작성 -->
		<c:if test="${not empty sessionScope.loginMember}">
		    <div class="container mt-3">
		        <div class="bg-body-bg rounded-3 p-3">
		                <h6 class="mb-2 fw-bold"><i class="fas fa-bolt text-danger me-1"></i>선정성 평가</h5>
		                <c:import url="/review/saveSexualUserScore">
		                    <c:param name="movieId" value="${movie.id}" />
		                </c:import>
		        </div>
		    </div>
		</c:if>

	<!-- 리뷰 작성 -->
	<div class="container mt-3">
	  <div class="bg-body-bg rounded-3 p-3">
	    <c:import url="/review/content">
	      <c:param name="movieId" value="${movie.id}" />
	    </c:import>
	  </div>
	</div>
	
	<!-- 태그 작성 -->
	<c:if test="${not empty sessionScope.loginMember}">
	<div class="container mt-3">
	  <div class="bg-body-bg rounded-3 p-3">
	            <c:import url="/review/tag">
	                <c:param name="movieId" value="${movie.id}" />
	            </c:import>
	 </div>
	</div>
	</c:if>

<!-- 다른 유저의 리뷰 리스트 -->
	<div class="container mt-4 mb-5">
	    <div class="p-3">
	        <h5 class="fw-bold mb-3">
	            <i class="fas fa-comments text-primary me-1"></i>코멘트
	        </h5>
	        <c:import url="/review/list">
	            <c:param name="movieId" value="${movie.id}" />
	        </c:import>
	    </div>
	 </div>
	</div>
</div>
<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 -->
<div class="d-block d-md-none" style="height: 80px;"></div>



<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script>
    $(document).ready(function() {
        $(document).off('click', '#toggleFavoriteBtn').on('click', '#toggleFavoriteBtn', function() {
            const movieId = $(this).data('movie-id');
            const button = $(this);
            const likeCountDetailSpan = $('#likeCountDetail');

            if (button.hasClass('processing')) return;

            button.addClass('processing').prop('disabled', true);

            $.ajax({
                url: '${pageContext.request.contextPath}/movies/' + movieId + '/toggleCart',
                type: 'POST',
                success: function(response) {
                    if (response.status === 'added') {
                        button.text('찜 목록에서 제거');
                        button.data('is-liked', true);
                        alert("찜 목록에 추가되었습니다.");
                    } else if (response.status === 'removed') {
                        button.text('찜 목록에 추가');
                        button.data('is-liked', false);
                        alert("찜 목록에서 제거되었습니다.");
                    }
                    if (response.newLikeCount !== undefined) {
                        likeCountDetailSpan.text(`총 ${response.newLikeCount}명 찜`);
                    }
                },
                error: function(xhr) {
                    alert("찜 처리 중 오류가 발생했습니다: " + xhr.responseText);
                },
                complete: function() {
                    button.removeClass('processing');
                    if (button.data('is-liked') !== undefined) {
                        button.prop('disabled', false);
                    }
                }
            });
        });
    });
</script>
</body>
</html>