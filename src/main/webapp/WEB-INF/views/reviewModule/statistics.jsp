<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ page import="java.util.Map, java.util.List, java.util.ArrayList, java.util.Map.Entry" %>
<%
    Object raw = request.getAttribute("genreStats");
    if (raw != null && raw instanceof Map) {
        Map<String, Integer> stats = (Map<String, Integer>) raw;
        List<Map.Entry<String, Integer>> sortedStats = new ArrayList<>(stats.entrySet());
        sortedStats.sort((a, b) -> b.getValue() - a.getValue());
        pageContext.setAttribute("sortedGenreStats", sortedStats); // 반드시 pageContext 사용
    } else {
        pageContext.setAttribute("sortedGenreStats", java.util.Collections.emptyList());
    }
%>

<c:if test="${not empty sortedGenreStats}">
  <div class="box p-3 border rounded">
    <h3>자주 평가한 장르</h3>
    <p>
      사용자님은 
      <c:forEach var="entry" items="${sortedGenreStats}" varStatus="loop">
        <c:set var="genre" value="${entry['key']}" />
        <c:set var="count" value="${entry['value']}" />
        <c:if test="${count > 0 && loop.index lt 3}">
          <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
        </c:if>
      </c:forEach>
      장르를 많이 평가하셨어요!
    </p>
  </div>
</c:if>

<c:if test="${not empty positiveGenreStats}">
  <c:set var="hasPositive" value="false" />
  <c:forEach var="entry" items="${positiveGenreStats}">
    <c:if test="${entry.value > 0}">
      <c:set var="hasPositive" value="true" />
    </c:if>
  </c:forEach>

  <c:if test="${hasPositive}">
    <div class="box p-3 border rounded">
      <h3>긍정적으로 평가한 장르</h3>
      <p>
        사용자님은 
        <c:forEach var="entry" items="${positiveGenreStats}" varStatus="loop">
          <c:set var="genre" value="${entry.key}" />
          <c:set var="count" value="${entry.value}" />
          <c:if test="${count > 0 && loop.index lt 3}">
            <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
          </c:if>
        </c:forEach>
        장르에 긍정적인 점수를 많이 주셨네요!
      </p>
    </div>
  </c:if>
</c:if>
