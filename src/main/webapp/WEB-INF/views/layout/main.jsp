<%--
    파일명: main.jsp
    설명:
        이 header.jsp 파일은 의 메인 콘텐츠 영역, 특히 홈페이지에 표시될 "최근 등록된 영화" 목록을 정의합니다.

    목적:
        - 웹사이트의 최근 등록된 영화를 노출하기 위함.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> <%-- 평점 포맷팅을 위해 fmt 태그 라이브러리 유지--%>
<div class="container">
    <h2 class="section-title">최근 등록된 영화</h2>
    <div class="movie-grid">
        <c:choose>
            <c:when test="${not empty movies}">
                <c:forEach var="movie" items="${movies}">
                    <div class="movie-card">
                        <%--`movieController.java`의 `detail` (GET /movies/{id}) 메서드로 연결.--%>
                        <a href="<c:url value='/movies/${movie.id}'/>">
                            <c:set var="posterSrc">
                                <c:choose>
                                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                        <c:if test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                            ${movie.posterPath}
                                        </c:if>
                                        <c:if test="${not (fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://'))}">
                                            ${pageContext.request.contextPath}${movie.posterPath}
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        ${pageContext.request.contextPath}/resources/images/default_poster.jpg
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <%--
                                `movie.posterPath`: `movie` 도메인 객체의 `posterPath` 필드에서 이미지 경로를 가져옴.
                                `fn:startsWith(..., 'http://')` 또는 `https://`:
                                    - JSTL Functions 라이브러리(`fn`)를 사용하여 `posterPath`가 완전한 URL인지 확인합니다.
                                    - 외부 API에서 가져온 이미지는 외부 URL이므로 직접 사용하고, 로컬에 저장된 이미지는 컨텍스트 경로를 붙여줍니다.
                                    (직접 영화를 등록 시 이미지가 웹 페이지에서 깨지는 경우가 생겨 해당 함수 사용.)
                                    - `movieController.java`에서 이미지 저장 시 `UPLOAD_DIRECTORY_RELATIVE` 상수를 사용하여 경로를 설정합니다.
                                `default_poster.jpg`:
                                    - `posterPath`가 없거나 "N/A"일 경우 표시되는 기본 이미지입.
                                    - `externalMovieApiService`에서 포스터 정보가 없을 때 "N/A"로 설정.
                                    - `movieController`에서 업로드된 파일이 없을 때 `movie.setPosterPath(null)`로 설정.
                            --%>
                            <img src="${posterSrc}" alt="${movie.title} 포스터" />
                            <%-- 영화 제목, 연도, 장르, 평점, 폭력성 지수 표시--%>
                            <h3>${movie.title}</h3>
                            <p>${movie.year} | ${movie.genre}</p>
                            <p>평점: ${movie.rating}</p>
                            <p>폭력성 지수: ${movie.violence_score_avg}</p>
                        </a>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p>아직 등록된 영화가 없습니다. <a href="<c:url value='/movies/new'/>">새 영화를 등록</a>하거나 <a href="<c:url value='/movies'/>">영화 목록</a>에서 API를 통해 가져와보세요!</p>
            <%--
                등록된 영화가 없는 경우 해당 메세지 출력.
                `movieController.java`의 `createForm` (GET /movies/new) 메서드로 연결. (관리자 권한 필요)
                `movieController.java`의 `list` (GET /movies) 메서드로 연결됩니다.
            --%>
            </c:otherwise>
        </c:choose>
    </div>
</div>