var template = "<div class='row'>[server1][server2]</div>";
var serverTemplate = "<div class='col-md-6 col-sm-12'><h2>[name]</h2></div>"

var refresh = function() {
    var focusedID = "";
    var name = "";
    var ip = $("#server-ip").val();
    var subnet = $("#server-subnet").val();
    var mac = $("#server-mac").val();


    if ($("#server-name").length > 0) {
        name = $("#server-name").val();

        focusedID = document.activeElement ? document.activeElement.id : "";
    }
    if ($("#server-ip").length > 0) {
        ip = $("#server-ip").val();
    }
    if ($("#server-subnet").length > 0) {
        subnet = $("#server-subnet").val();
    }
    if ($("#server-name").length > 0) {
        mac = $("#server-mac").val();
    }

    $('#container').load("/Servers?layout=table",
        function() {
            $("#server-name").val(name);
            $("#server-ip").val(ip);
            $("#server-subnet").val(subnet);
            $("#server-mac").val(mac);

            if (focusedID !== "") {
                $("#" + focusedID).focus();
            }

            $(".overlay").remove();

            $("#autofill-mac").on("click",
                function() {
                    var ip = $("#server-ip").val();

                    if (ip.length === 0) {
                        return window.toastr.error("Please enter IP!");
                    }

                    $.ajax({
                        url: "api/Server/mac/" + ip,
                        statusCode: {
                            400: function() {
                                window.toastr.error("Server does not respond!");
                            }
                        }
                    }).done(function (resp) {
                        $("#server-mac").val(resp);
                    }).fail(function(jqXHR, text, error) {
                        return window.toastr.error(text);
                    });
                }
            );
            $("#submit").on("click",
                function() {
                    var n = $("#server-name").val();
                    var i = $("#server-ip").val();
                    var s = $("#server-subnet").val();
                    var m = $("#server-mac").val();

                    if (n.length === 0 || i.length === 0 || s.length === 0 || m.length === 0) {
                        return window.toastr.error("Please enter all values!");
                    }

                    $.ajax({
                        url: "api/Server",
                        method: "POST",
                        data: JSON.stringify({ Name: n, IP: i, Subnet: s, MAC: m, ID: 0, Online: false }),
                        contentType: "application/json",
                        statusCode: {
                            201: function() {
                                $("#server-name").val("");
                                $("#server-ip").val("");
                                $("#server-subnet").val("");
                                $("#server-mac").val("");
                                refresh();
                            },
                            400: function() {
                                window.toastr.error("Could not create Server! Make sure all values are correct!");
                            }
                        }
                    });
                }
            );

            $(".wake-server").on("click",
                function() {
                    $.ajax({
                        url: "api/Server/wake/" + $(this).data("server-id"),
                        statusCode: {
                            400: function() {
                                window.toastr.error("Wake Up failed! Server not responding!",
                                    { position: "bottom-left" });
                            },
                            404: function() {
                                window.toastr.error("This Server does not exist in the Database!",
                                    { position: "bottom-left" });
                            },
                            200: function() {
                                window.toastr.success("Server is Online!", { position: "bottom-left" });
                                refresh();
                            }
                        }
                    });
                }
            );

            $(".delete-server").on("click",
                function() {
                    $.ajax({
                        url: "api/Server/" + $(this).data("server-id"),
                        method: "DELETE",
                        statusCode: {
                            200: function() {
                                window.toastr.success("Server deleted!");
                                refresh();
                            },
                            404: function() {
                                window.toastr.error("Server does not exist!");
                                refresh();
                            }
                        }
                    });
                }
            );
        }
    );
}

$(function() {
    window.toastr.options.closeButton = true;
    window.toastr.options.newestOnTop = false;
    window.toastr.options.progressBar = true;
    refresh();

    setInterval(refresh, 60 * 1000); // 1 minute
});