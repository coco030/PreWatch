<%--
    파일명: header.jsp
    설명:
        이 JSP 파일은 home.jsp의 전체 헤더 영역을 정의합니다.

    목적:
        - 홈페이지의 상단 내비게이션 및 핵심 기능을 제공하기 위함.

--%>
<%@ page contentType="text/html; charset=UTF-8" %>
<div class="header-wrapper">
    <jsp:include page="/WEB-INF/views/layout/header-left.jsp" />
    <jsp:include page="/WEB-INF/views/layout/header-center.jsp" />
    <jsp:include page="/WEB-INF/views/layout/header-right.jsp" />
</div>