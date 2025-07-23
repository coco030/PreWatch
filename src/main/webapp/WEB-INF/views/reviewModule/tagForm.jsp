<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% System.out.println("tagForm 진입"); %>

<input type="hidden" id="movieId" value="${movieId}" />

<p>
  <strong>태그 : </strong>
  <c:choose>
    <c:when test="${not empty myReview and not empty myReview.tags}">
      <span style="color:gray; font-size:0.9em">#${fn:replace(myReview.tags, ',', ' #')}</span>
    </c:when>
    <c:otherwise>
      <span style="color:gray;">아직 태그를 달지 않으셨어요.</span>
    </c:otherwise>
  </c:choose>
</p>

<input type="text"
       id="tag"
       name="tag"
       placeholder="예: 절단장면있음, 잔인함 (쉼표로 구분)"
       style="width:100%; padding:8px;" />

<script>
(function(){
    // jQuery가 있는지 확인 (안전망)
    if (typeof $ === 'undefined') {
        console.error("jQuery 가 로드되지 않았습니다. 태그 입력 기능이 비활성화됩니다.");
        return;
    }

    $('#tag').on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const movieId = $('#movieId').val();
            const tag = $('#tag').val().trim();

            if (!tag) {
                alert("태그를 입력하세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "${pageContext.request.contextPath}/review/saveTag",
                data: { movieId: movieId, tag: tag },
                success: function (response) {
                    if (response.success) {
                        alert("태그 저장됨: " + tag);
                        $('#tag').val("");
                        // 태그 표시 영역 갱신 (선택)
                        // location.reload(); // 전체 리로드 대신 부분 업데이트도 가능
                    } else {
                        alert("실패: " + (response.message || '알 수 없는 오류'));
                    }
                },
                error: function (xhr) {
                    alert("태그 저장 중 오류: " + xhr.status);
                }
            });
        }
    });
})();
</script>
