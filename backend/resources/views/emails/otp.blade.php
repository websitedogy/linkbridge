<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Welcome to Linkbridge</title>
</head>
<body style="margin:0;padding:0;background:#F7F8F6;font-family:Arial,Helvetica,sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:32px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border:1px solid #E5E7EB;border-radius:16px;padding:32px;">
                    <tr>
                        <td>
                            <p style="margin:0 0 8px;color:#D4A537;font-size:12px;font-weight:700;letter-spacing:2px;">LINKSBRIDGE</p>
                            <h1 style="margin:0 0 12px;color:#1F4D3A;font-size:26px;">Welcome to Linkbridge</h1>
                            <p style="margin:0 0 16px;color:#6B7280;font-size:15px;line-height:1.5;">
                                Hello {{ $recipientName }},
                            </p>
                            <p style="margin:0 0 16px;color:#1A1F1C;font-size:15px;line-height:1.5;">
                                Buy. Sell. Grow. Connecting serious buyers and trusted sellers in one marketplace.
                            </p>
                            <p style="margin:0 0 20px;color:#1A1F1C;font-size:15px;line-height:1.5;">
                                Use this one-time code to continue:
                            </p>
                            <p style="margin:0 0 24px;color:#1F4D3A;font-size:32px;font-weight:800;letter-spacing:8px;">
                                {{ $code }}
                            </p>
                            <p style="margin:0;color:#6B7280;font-size:13px;line-height:1.5;">
                                This code expires in 10 minutes. If you did not ask for it, you can ignore this email.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
