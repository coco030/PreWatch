<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% System.out.println("tagForm 진입"); %>
<hr>
<!-- 영화 ID -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="memberId" value="${loginMember.id}" />
</c:if>

<!-- 태그 표시 영역 -->
<div id="tag-section" class="my-4">
    <p style="color: gray; font-size: em; margin-bottom: 6px;">
        <c:choose>
            <c:when test="${not empty myReview and not empty myReview.tags}">
                <span id="tagList">#${fn:replace(myReview.tags, ',', ' #')}</span>
            </c:when>
            <c:otherwise>
                <span id="tagList">아직 태그를 달지 않으셨어요.</span>
            </c:otherwise>
        </c:choose>
    </p>

    <!-- 로그인 여부에 따라 태그 입력 or 안내 -->
    <c:choose>
        <c:when test="${not empty loginMember}">
            <input type="text"
                   id="tagInput"
                   name="tag"
                   placeholder="예: 절단장면있음, 잔인함 (쉼표로 구분)"
                   style="width:100%; padding:8px;" />
        </c:when>
        <c:otherwise>
            <div style="color: gray; font-size: 0.9em; margin-top: 6px;">
                태그를 추가하려면 로그인해주세요.
            </div>
        </c:otherwise>
    </c:choose>
</div>


<!-- JS (입력 Ajax 처리) -->
<script>
(function(){
    if (typeof $ === 'undefined') {
        console.error("jQuery 미탑재 - 태그 입력 불가");
        return;
    }

    $('#tagInput').on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const movieId = $('#movieId').val();
            const tag = $('#tagInput').val().trim();

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
                        $('#tagInput').val("");

                        // 태그 표시 갱신
                        if (response.updatedTags) {
                            const tags = response.updatedTags.split(',').map(t => '#' + t.trim()).join(' ');
                            $('#tagList').text(tags);
                        }
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
