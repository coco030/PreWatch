<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("홈 뷰 진입"); %> 
<html>
<head>
    <title>PreWatch: 나만의 영화 피디아</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>?v=home-overview-20260611">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: Arial, sans-serif; }
    </style>
</head>
<body>

    <%-- 헤더 영역 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <%-- 메인 영역 --%>
    <main>
        <div>
            <jsp:include page="/WEB-INF/views/layout/main.jsp" />
        </div>
    </main>
<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 
<div class="d-block d-md-none" style="height: 80px;"></div> -->
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
