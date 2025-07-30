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
        <%-- 07.30 coco030 개봉일 추가 --%>    
       <p><strong>개봉일:</strong> 
        <c:choose>
            <c:when test="${not empty movie.runtime and movie.runtime ne 'N/A'}">
                ${movie.releaseDate}
            </c:when>
            <c:otherwise>
                정보 없음
            </c:otherwise>
        </c:choose>
    </p>


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

  <p>
    <i class="bi-emoji-dizzy-fill text-secondary me-1"></i>
    <strong>평균 공포 지수:</strong>
    <c:choose>
        <c:when test="${movie_stats.avgHorrorScore == null || avgHorrorScore == 0}">
            N/A
        </c:when>
        <c:otherwise>
            <fmt:formatNumber value="${avgHorrorScore}" pattern="#0.0" />
        </c:otherwise>
    </c:choose>
     / 10.0
</p>
<p>

  <p>
    <i class="bi-eye-fill text-warning me-1"></i>
    <strong>평균 선정성 지수:</strong>
    <c:choose>
        <c:when test="${movie_stats.avgSexualScore == null || avgSexualScore == 0}">
            N/A
        </c:when>
        <c:otherwise>
            <fmt:formatNumber value="${avgSexualScore}" pattern="#0.0" />
        </c:otherwise>
    </c:choose>
     / 10.0
</p>
<p>

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

 <!-- 출연자 정보가 하나도 없을 땐 조건문으로 감싸서 안 이 섹션을 안 보이게-->
<c:if test="${not empty dbCastList or not empty castAndCrew}">
<!-- 주요 참여진 박스 전체를 카드로 감싸기 -->
<div class="card bg mb-4" style="border:none;">
  <div class="card-body">
    <h5 class="mb-2">출연/제작</h2>
    <ul class="list-unstyled d-flex flex-wrap gap-3" style="margin-top:8px; padding-left:0;">
		
		  <!-- 1. DB(저장된) 출연진 리스트: 감독 먼저, 그 다음 배우/성우/기타 -->
		  <c:if test="${not empty dbCastList}">
		    <!-- 1-1. 감독 먼저 -->
		    <c:forEach var="person" items="${dbCastList}">
		      <c:if test="${person.role_type eq 'DIRECTOR'}">
		        <li style="width:128px; text-align:center;">
		          <a href="${pageContext.request.contextPath}/directors/${person.id}" style="text-decoration:none; color:inherit;">
		            <!-- 동그라미 프로필 -->
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
		            <!-- 라벨(감독) -->
		            <div>
		              <span class="badge bg-primary">감독</span>
		            </div>
		            <!-- 이름 -->
		            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
		              ${person.name}
		            </div>
		            <!-- 역할명 -->
		            <div style="color:#888; font-size:0.93em;">
		              <c:if test="${not empty person.role_name}">${person.role_name}</c:if>
		            </div>
		          </a>
		        </li>
		      </c:if>
		    </c:forEach>
		    <!-- 1-2. 배우/성우/기타 -->
		    <c:forEach var="person" items="${dbCastList}">
		      <c:if test="${person.role_type ne 'DIRECTOR'}">
		        <li style="width:128px; text-align:center;">
		          <a href="${pageContext.request.contextPath}/actors/${person.id}" style="text-decoration:none; color:inherit;">
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
		            <!-- 라벨(배우/성우/기타) -->
		            <div>
		              <c:choose>
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
		            <!-- 이름 -->
		            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
		              ${person.name}
		            </div>
		            <!-- 역할명 -->
		            <div style="color:#888; font-size:0.93em;">
		              <c:if test="${not empty person.role_name}">${person.role_name}</c:if>
		            </div>
		          </a>
		        </li>
		      </c:if>
		    </c:forEach>
		  </c:if>
      </ul>
  </div>
</div>

  <!-- 2. TMDB 실시간 출연진 (dbCastList가 비어있을 때만) -->
<c:if test="${empty dbCastList && not empty castAndCrew}">
  <ul class="list-unstyled d-flex flex-wrap gap-3" style="margin-top:8px; padding-left:0;">
    
    <!-- 1. 감독 먼저 출력 -->
    <c:forEach var="person" items="${castAndCrew}">
      <c:if test="${person.type eq 'DIRECTOR'}">
        <li style="width:128px; text-align:center;">
          <a style="text-decoration:none; color:inherit;">
            <!-- 프로필 이미지 -->
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

            <!-- 배지 -->
            <div><span class="badge bg-primary">감독</span></div>

            <!-- 이름 -->
            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
              ${person.name}
            </div>

            <!-- 역할명 (없을 수도 있음) -->
            <div style="color:#888; font-size:0.93em;">
              <c:if test="${not empty person.role}">${person.role}</c:if>
            </div>
          </a>
        </li>
      </c:if>
    </c:forEach>

    <!-- 2. 배우/성우/기타 출력 -->
    <c:forEach var="person" items="${castAndCrew}">
      <c:if test="${person.type ne 'DIRECTOR'}">
        <li style="width:128px; text-align:center;">
          <a style="text-decoration:none; color:inherit;">
            <!-- 프로필 이미지 -->
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

            <!-- 배지 -->
            <div>
              <c:choose>
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

            <!-- 이름 -->
            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
              ${person.name}
            </div>

            <!-- 역할명 -->
            <div style="color:#888; font-size:0.93em;">
              <c:if test="${not empty person.role}">${person.role}</c:if>
            </div>
          </a>
        </li>
      </c:if>
    </c:forEach>
  </ul>
</c:if>
</div>
</c:if>
	                
	<!-- 별점 작성 -->
	<c:if test="${not empty sessionScope.loginMember}">
	    <div class="container mt-3">
	        <div class="bg-body-bg rounded-3 p-3">
	                <h6 class="mb-2 fw-bold"><i class="fas fa-star text-warning me-1"></i>만족도 평가</h6>
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
	                <h6 class="mb-2 fw-bold"><i class="bi-exclamation-triangle-fill text-danger me-1"></i>폭력성 평가</h6>
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
		                <h6 class="mb-2 fw-bold"><i class="bi-emoji-dizzy-fill text-secondary me-1"></i>
							공포지수 평가</h6>
		                <c:import url="/review/HorrorScoreUserView">
		                    <c:param name="movieId" value="${movie.id}" />
		                </c:import>
		        </div>
		    </div>
		</c:if>
		
		<!-- 선정성 지수 작성 -->
		<c:if test="${not empty sessionScope.loginMember}">
		    <div class="container mt-3">
		        <div class="bg-body-bg rounded-3 p-3">
		                <h6 class="mb-2 fw-bold"><i class="bi-eye-fill text-warning me-1"></i>
							선정성 평가</h6>
		                <c:import url="/review/SexualScoreUserView">
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
<c:if test="${not empty reviewList}">
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
</c:if>


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