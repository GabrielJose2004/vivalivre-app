import 'package:flutter/material.dart';
import 'star_rating_widget.dart';

/// Form widget for submitting reviews with rating and comment.
///
/// Includes:
/// - Star rating selector (required)
/// - Comment text field (optional)
/// - Submit button
/// - Form validation
class ReviewFormWidget extends StatefulWidget {
  final Function(int rating, String comment) onSubmit;
  final bool isLoading;
  final String? initialRating;

  const ReviewFormWidget({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialRating,
  });

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late double _selectedRating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating != null ? double.parse(widget.initialRating!) : 0;
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona uma classificação em estrelas')),
        );
        return;
      }

      widget.onSubmit(_selectedRating.toInt(), _commentController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Label
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Tua avaliação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          // Star Rating Widget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: StarRatingWidget(
              initialRating: _selectedRating,
              onRatingChanged: (rating) {
                setState(() => _selectedRating = rating);
              },
            ),
          ),

          // Comment Field
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextFormField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'Deixa um comentário (opcional)',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                counterText: '',
              ),
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Máximo 500 caracteres';
                }
                return null;
              },
            ),
          ),

          // Character Counter
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_commentController.text.length}/500',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Submetendo...'),
                      ],
                    )
                  : const Text('Submete a Avaliação'),
            ),
          ),
        ],
      ),
    );
  }
}
