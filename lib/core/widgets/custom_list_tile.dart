import 'package:habitrise/core/core.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    super.key,
    required this.title,
    this.description,
    this.secondaryDescription,
    this.leading,
    this.additionalInfo,
    this.trailing,
    this.onPressed,
  });

  final String title;
  final String? description;
  final Widget? leading;
  final String? secondaryDescription;
  final Widget? trailing;
  final Widget? additionalInfo;
  final Function()? onPressed;

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: widget.onPressed,
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.left,
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.titleMedium?.color?.withValues(alpha: 0.9),
                        ),
                      ),
                      if (widget.secondaryDescription != null)
                        Text(
                          widget.secondaryDescription!,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium?.copyWith(
                            color: context.bodyMedium?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      if (widget.description != null && widget.description!.isNotEmpty)
                        Text(
                          widget.description!,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium?.copyWith(
                            color: context.bodyMedium?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.additionalInfo != null) ...[
                  const SizedBox(width: 10),
                  widget.additionalInfo!,
                ],
                if (widget.trailing != null) ...[
                  const SizedBox(width: 10),
                  widget.trailing!,
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
