<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("홈 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 나만의 영화 피디아</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body>

    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <%-- 메인 콘텐츠 (영화 목록 등) --%>
    <main>
        <div>
            <jsp:include page="/WEB-INF/views/layout/main.jsp" />
        </div>
    </main>

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
