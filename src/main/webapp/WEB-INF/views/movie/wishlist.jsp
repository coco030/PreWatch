<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%System.out.println("wishlist 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<title>wishlist</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
<body>

<c:choose>
    <c:when test="${not empty likedMovies}">
        <ul>
            <c:forEach var="movie" items="${likedMovies}">
                <li>
                    <a href="<c:url value='/movies/${movie.id}' />">${movie.title}</a>
                    <span>(${movie.year})</span>
                </li>
            </c:forEach>
        </ul>
    </c:when>
    <c:otherwise>
        <p>찜한 영화가 없습니다.</p>
    </c:otherwise>
</c:choose>

    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>