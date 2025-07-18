<%--
    파일명: home.jsp
    설명:
        이 JSP 파일은 홈페이지입니다.

    목적:
        - 사용자가 웹사이트에 처음 접속했을 때 보여주는 화면.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("홈 뷰 진입"); %> 
<%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 나만의 영화 피디아</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
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

    <%-- 푸터 영역  --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>